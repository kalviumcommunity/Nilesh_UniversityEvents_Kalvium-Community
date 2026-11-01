const { initializeApp } = require('firebase-admin/app');
const { FieldValue, Timestamp, getFirestore } = require('firebase-admin/firestore');
const { HttpsError, onCall } = require('firebase-functions/v2/https');

initializeApp();
const db = getFirestore();

const isManager = (request) =>
  request.auth && ['admin', 'coordinator'].includes(request.auth.token.role);

const requireManager = (request) => {
  if (!isManager(request)) {
    throw new HttpsError('permission-denied', 'Coordinator or administrator access is required.');
  }
};

const requireString = (value, label, maximum = 200) => {
  if (typeof value !== 'string' || value.trim().length === 0 || value.length > maximum) {
    throw new HttpsError('invalid-argument', `${label} is required and must be at most ${maximum} characters.`);
  }
  return value.trim();
};

const assertCanManageEvent = async (request, eventSnapshot) => {
  requireManager(request);
  if (
    request.auth.token.role !== 'admin' &&
    eventSnapshot.data().ownerId !== request.auth.uid
  ) {
    throw new HttpsError('permission-denied', 'You can only manage events created by your account.');
  }
};

exports.createEvent = onCall(async (request) => {
  requireManager(request);
  const title = requireString(request.data?.title, 'Event title', 120);
  const venue = requireString(request.data?.venue, 'Venue', 160);
  const description = requireString(request.data?.description, 'Description', 3000);
  const category = requireString(request.data?.category, 'Category', 32);
  if (!['Workshop', 'Talk', 'Hackathon', 'Festival'].includes(category)) {
    throw new HttpsError('invalid-argument', 'Choose a supported event category.');
  }
  const startAt = new Date(request.data?.startAt);
  if (!Number.isFinite(startAt.getTime())) {
    throw new HttpsError('invalid-argument', 'A valid event date and time are required.');
  }
  if (startAt.getTime() < Date.now() - 60 * 60 * 1000) {
    throw new HttpsError('invalid-argument', 'Event start time must be in the future.');
  }

  const profile = await db.collection('users').doc(request.auth.uid).get();
  const profileData = profile.data() || {};
  const event = {
    title,
    category,
    type: category === 'Workshop' ? 'Workshops' : 'Events',
    venue,
    place: venue,
    description,
    startAt: Timestamp.fromDate(startAt),
    endAt: Timestamp.fromDate(new Date(startAt.getTime() + 3 * 60 * 60 * 1000)),
    status: 'Upcoming',
    published: true,
    ownerId: request.auth.uid,
    clubId: profileData.clubId || null,
    clubName: profileData.clubName || 'Campus Club',
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
  const ref = await db.collection('events').add(event);
  return { eventId: ref.id };
});

exports.registerForEvent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in before registering for an event.');
  }
  const eventId = requireString(request.data?.eventId, 'Event ID', 128);
  const role = request.data?.role;
  if (!['Participant', 'Volunteer'].includes(role)) {
    throw new HttpsError('invalid-argument', 'Choose Participant or Volunteer.');
  }
  const additionalInformation = typeof request.data?.additionalInformation === 'string'
    ? request.data.additionalInformation.trim().slice(0, 500)
    : '';
  const eventRef = db.collection('events').doc(eventId);
  const registrationRef = db.collection('registrations').doc(`${eventId}_${request.auth.uid}`);

  await db.runTransaction(async (transaction) => {
    const [event, registration] = await Promise.all([
      transaction.get(eventRef),
      transaction.get(registrationRef),
    ]);
    if (!event.exists || event.data().published !== true) {
      throw new HttpsError('not-found', 'This event is not available for registration.');
    }
    if (registration.exists) {
      throw new HttpsError('already-exists', 'You are already registered for this event.');
    }
    const userRef = db.collection('users').doc(request.auth.uid);
    const user = await transaction.get(userRef);
    if (!user.exists) {
      throw new HttpsError('failed-precondition', 'Complete your profile before registering.');
    }
    transaction.create(registrationRef, {
      userId: request.auth.uid,
      eventId,
      eventTitle: event.data().title,
      role,
      additionalInformation,
      userName: user.data().name || '',
      userEmail: user.data().email || '',
      createdAt: FieldValue.serverTimestamp(),
    });
    const ownerId = event.data().ownerId;
    if (ownerId && ownerId !== request.auth.uid) {
      const notificationRef = db.collection('notifications').doc();
      transaction.create(notificationRef, {
        userId: ownerId,
        title: 'New registration',
        body: `${user.data().name || 'A student'} registered for ${event.data().title}.`,
        type: 'Events',
        eventId,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    transaction.update(eventRef, {
      registrationCount: FieldValue.increment(1),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return { registered: true };
});

exports.assignVolunteers = onCall(async (request) => {
  const eventId = requireString(request.data?.eventId, 'Event ID', 128);
  const volunteerUids = request.data?.volunteerUids;
  if (
    !Array.isArray(volunteerUids) ||
    volunteerUids.length === 0 ||
    volunteerUids.length > 50 ||
    volunteerUids.some((uid) => typeof uid !== 'string' || uid.length > 128)
  ) {
    throw new HttpsError('invalid-argument', 'Select between 1 and 50 volunteers.');
  }

  const eventRef = db.collection('events').doc(eventId);
  const event = await eventRef.get();
  if (!event.exists) throw new HttpsError('not-found', 'Event not found.');
  await assertCanManageEvent(request, event);

  const uniqueUids = [...new Set(volunteerUids)];
  const refs = uniqueUids.map((uid) => db.collection('users').doc(uid));
  const profiles = await db.getAll(...refs);
  const invalidVolunteer = profiles.find((profile) =>
    !profile.exists || profile.data().role !== 'student'
  );
  if (invalidVolunteer) {
    throw new HttpsError('invalid-argument', 'Only existing student accounts can be assigned.');
  }

  const assignmentRefs = uniqueUids.map((uid) =>
    db.collection('assignments').doc(`${eventId}_${uid}`)
  );
  const notificationRefs = uniqueUids.map(() =>
    db.collection('notifications').doc()
  );
  const assignedCount = await db.runTransaction(async (transaction) => {
    const existingAssignments = await transaction.getAll(...assignmentRefs);
    let newlyAssigned = 0;
    uniqueUids.forEach((uid, index) => {
      if (existingAssignments[index].exists) return;
      transaction.create(assignmentRefs[index], {
        eventId,
        eventTitle: event.data().title,
        volunteerUid: uid,
        volunteerName: profiles[index].data().name || '',
        role: 'Volunteer',
        status: 'assigned',
        assignedBy: request.auth.uid,
        assignedAt: FieldValue.serverTimestamp(),
        respondedAt: null,
      });
      transaction.create(notificationRefs[index], {
        userId: uid,
        title: 'Volunteer assignment',
        body: `You have been invited to volunteer for ${event.data().title}.`,
        type: 'Mentions',
        eventId,
        createdAt: FieldValue.serverTimestamp(),
      });
      newlyAssigned += 1;
    });
    return newlyAssigned;
  });
  return { assigned: assignedCount };
});

exports.respondToAssignment = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in to respond.');
  const assignmentId = requireString(request.data?.assignmentId, 'Assignment ID', 180);
  const status = request.data?.status;
  if (!['confirmed', 'declined'].includes(status)) {
    throw new HttpsError('invalid-argument', 'Response must be confirmed or declined.');
  }

  const assignmentRef = db.collection('assignments').doc(assignmentId);
  await db.runTransaction(async (transaction) => {
    const assignment = await transaction.get(assignmentRef);
    if (!assignment.exists || assignment.data().volunteerUid !== request.auth.uid) {
      throw new HttpsError('not-found', 'Assignment not found.');
    }
    if (assignment.data().status !== 'assigned') {
      throw new HttpsError('failed-precondition', 'This assignment has already been answered.');
    }
    transaction.update(assignmentRef, {
      status,
      respondedAt: FieldValue.serverTimestamp(),
    });
    const assignedBy = assignment.data().assignedBy;
    if (assignedBy) {
      const notificationRef = db.collection('notifications').doc();
      transaction.create(notificationRef, {
        userId: assignedBy,
        title: 'Volunteer response',
        body: `${assignment.data().volunteerName || 'A volunteer'} ${status} the assignment for ${assignment.data().eventTitle || 'your event'}.`,
        type: 'Mentions',
        eventId: assignment.data().eventId,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
  });
  return { status };
});

exports.getEventReport = onCall(async (request) => {
  requireManager(request);
  const range = request.data?.range || 'This Month';
  if (!['This Month', 'Last Month', 'This Year'].includes(range)) {
    throw new HttpsError('invalid-argument', 'Choose a supported report range.');
  }
  const now = new Date();
  let start;
  if (range === 'This Year') {
    start = new Date(now.getFullYear(), 0, 1);
  } else if (range === 'Last Month') {
    start = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  } else {
    start = new Date(now.getFullYear(), now.getMonth(), 1);
  }
  const end = range === 'Last Month'
    ? new Date(now.getFullYear(), now.getMonth(), 1)
    : now;
  const startTimestamp = Timestamp.fromDate(start);
  const endTimestamp = Timestamp.fromDate(end);
  let eventsQuery = db.collection('events');
  if (request.auth.token.role !== 'admin') {
    eventsQuery = eventsQuery.where('ownerId', '==', request.auth.uid);
  }
  const events = await eventsQuery.get();
  const eventIds = events.docs.map((event) => event.id);
  const registrations = request.auth.token.role === 'admin'
    ? (await db.collection('registrations')
      .where('createdAt', '>=', startTimestamp)
      .where('createdAt', '<', endTimestamp)
      .count()
      .get()).data().count
    : await countForEvents('registrations', 'createdAt', eventIds, startTimestamp, endTimestamp);
  const volunteers = request.auth.token.role === 'admin'
    ? (await db.collection('assignments')
      .where('assignedAt', '>=', startTimestamp)
      .where('assignedAt', '<', endTimestamp)
      .count()
      .get()).data().count
    : await countForEvents('assignments', 'assignedAt', eventIds, startTimestamp, endTimestamp);
  const topEvents = await Promise.all(events.docs.map(async (event) => {
    const count = await db.collection('registrations')
      .where('eventId', '==', event.id)
      .where('createdAt', '>=', startTimestamp)
      .where('createdAt', '<', endTimestamp)
      .count()
      .get();
    return {
      title: event.data().title || 'Untitled Event',
      registrations: count.data().count,
    };
  }));
  topEvents.sort((a, b) => b.registrations - a.registrations);
  return {
    events: events.size,
    registrations,
    volunteers,
    topEvents: topEvents.slice(0, 3),
  };
});

async function countForEvents(collection, dateField, eventIds, start, end) {
  let count = 0;
  for (let index = 0; index < eventIds.length; index += 30) {
    const ids = eventIds.slice(index, index + 30);
    const snapshot = await db.collection(collection)
      .where('eventId', 'in', ids)
      .where(dateField, '>=', start)
      .where(dateField, '<', end)
      .count()
      .get();
    count += snapshot.data().count;
  }
  return count;
}
