const admin = require('firebase-admin');
const { cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, Timestamp } = require('firebase-admin/firestore');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: cert(serviceAccount),
});

const auth = getAuth();
const db = getFirestore();

const PASSWORD = '123456';  // default password for all mock users

async function cleanDatabase() {
  console.log('Cleaning auth and firestore...');

  // delete all users from auth
  const listUsersResult = await auth.listUsers(1000);
  const uids = listUsersResult.users.map((user) => user.uid);
  if (uids.length > 0) {
    await auth.deleteUsers(uids);
    console.log(`deleted ${uids.length} users from auth.`);
  }

  // delete all collections
  const collections = ['users', 'jobs', 'applications', 'faceIndex'];
  for (const col of collections) {
    const snapshot = await db.collection(col).get();
    if (!snapshot.empty) {
      const batch = db.batch();
      snapshot.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
      console.log(`collection '${col}' emptied (${snapshot.size} documents).`);
    }
  }

  console.log('Firebase is clean.');
}

async function fillDatabase() {
  await cleanDatabase();

  console.log('Filling DB with mock data...');

  /// ADMIN ACCOUNT
  console.log('Creating Admin account...');
  const adminUser = await auth.createUser({
    email: 'admin@vagoflax.ch',
    password: PASSWORD,
    companyName: 'Admin',
  });

  await db.collection('users').doc(adminUser.uid).set({
    email: adminUser.email,
    role: 'admin',
    createdAt: new Date(),
  });

  /// STUDENT ACCOUNTS
  console.log('Creating students...');
  const studentsData = [
    {
      firstName: 'Gonçalo',
      lastName: 'Arieira Esteves',
      email: "gon@vagoflax.ch",
      description: 'Business Information Technology student at HES-SO Valais-Wallis.',
      canton: 'VS',
      address: 'Rue de l\'Envol 8, 1950 Sion',
      skills: ['Flutter', 'Dart', 'Python', 'Firebase', 'Git'],
      history: [
        {
          jobTitle: 'Software Development Intern',
          company: 'ALTIS Groupe SA',
          startedAt: Timestamp.fromDate(new Date('2025-09-01T08:00:00Z')),
          endedAt: Timestamp.fromDate(new Date('2026-06-30T17:00:00Z')),
        },
      ],
    },
    {
      firstName: 'Valentin',
      lastName: 'Monod',
      email: 'val@vagoflax.ch',
      description: 'Coffee and motorcycle enthusiast. Systems Engineering student at HEI Sion.',
      canton: 'VS',
      address: "Rte d'Outre-Vièze 131, 1871 Monthey",
      skills: ['Customer service', 'Event management', 'German C1', 'MS Office'],
      profilePictureUrl: 'https://isc.hevs.ch/learn/pluginfile.php/4523/user/icon/mb2nl/f1?rev=131019',
      history: [
{
          jobTitle: 'Seasonal Receptionist',
          company: 'Crans-Montana Hotel',
          startedAt: Timestamp.fromDate(new Date('2025-12-01T08:00:00Z')),
          endedAt: Timestamp.fromDate(new Date('2026-04-15T17:00:00Z')),
        },
      ],
    },
    {
      firstName: 'Florian',
      lastName: 'Favre',
      email: 'flo@vagoflax.ch',
      description: 'Energy and Environmental Engineering student. Rigorous, curious, and available for part-time jobs.',
      canton: 'VS',
      address: 'Chem. de la poya 138, 1997 Nendaz',
      skills: ['AutoCAD', 'Matlab', 'Thermodynamics', 'Herald License', 'League of Legends', 'Chaos ARAM'],
      history: [
        {
          jobTitle: 'Engineering Intern',
          company: 'OIKEN',
          startedAt: Timestamp.fromDate(new Date('2025-07-01T08:00:00Z')),
          endedAt: Timestamp.fromDate(new Date('2025-08-31T17:00:00Z')),
        },
      ],
    },
    {
      firstName: 'Axel',
      lastName: 'Hall',
      email: 'axe@vagoflax.ch',
      description: 'Business Administration student with a strong interest in digital marketing and local finance.',
      canton: 'VS',
      address: 'Rue des Vignerons 94, 1963 Vétroz',
      profilePictureUrl: 'https://res.cloudinary.com/oaqyf2ip/image/upload/v1788251100/renoi.avif',
      skills: ['Digital marketing', 'Cost accounting', 'Excel expert', 'Canva'],
      history: [
        {
          jobTitle: 'Administrative Assistant',
          company: 'Valais Fiduciary Services',
          startedAt: Timestamp.fromDate(new Date('2026-01-10T08:00:00Z')),
          endedAt: Timestamp.fromDate(new Date('2026-08-31T17:00:00Z')),
        },
      ],
    },
  ];

  const studentUids = [];
  for (const s of studentsData) {
    const createdUser = await auth.createUser({
      email: s.email,
      password: PASSWORD,
      displayName: `${s.firstName} ${s.lastName}`,
    });

    studentUids.push(createdUser.uid);

    await db.collection('users').doc(createdUser.uid).set({
      firstName: s.firstName,
      lastName: s.lastName,
      email: s.email,
      role: 'student',
      description: s.description,
      canton: s.canton,
      address: s.address,
      profilePictureUrl: s.profilePictureUrl || null,
      skills: s.skills,
      history: s.history,
      reviews: [],
      createdAt: new Date(),
    });
  }

  /// EMPLOYER ACCOUNTS AND JOB LISTINGS
  console.log('Creating employers and job listings...');
  const employersData = [
    {
      companyName: 'OIKEN',
      email: 'jobs@oiken.ch',
      description: 'Energy, water, and multimedia infrastructure provider in Central Valais.',
      canton: 'VS',
      address: "Rue de l'Industrie 43, 1951 Sion",
      profilePictureUrl: 'https://i.ytimg.com/vi/57oivOLxoKU/hqdefault.jpg',
      companySize: 500,
      jobs: [
        {
          title: 'Junior Full-Stack Developer (Student Job)',
          description: 'Participate in developing internal tools for smart electrical grid management.',
          diplomas: ['bachelor'],
          contractTime: 6,
          role: 'junior',
          industry: 'informationTechnology',
          perks: ['ag'],
          languages: ['french', 'english'],
          holidays: 25,
          maternityLeave: 16,
          paternityLeave: 3,
          workloadPercent: 40,
          salary: 26400.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'IT & Network Support Assistant',
          description: 'Level 1 & 2 technical support for agency users in Sion and Sierre.',
          diplomas: ['apprenticeship', 'bachelor'],
          contractTime: 12,
          role: 'junior',
          industry: 'informationTechnology',
          perks: [],
          languages: ['french'],
          holidays: 25,
          maternityLeave: 16,
          paternityLeave: 2,
          workloadPercent: 60,
          salary: 37200.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'Energy Transition & Data Intern',
          description: 'Analyze photovoltaic consumption data and build forecast models.',
          diplomas: ['bachelor', 'master'],
          contractTime: 4,
          role: 'intern',
          industry: 'informationTechnology',
          perks: ['car'],
          languages: ['french', 'german'],
          holidays: 20,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 100,
          salary: 45600.0,
          predictedSalary: null,
          visible: true,
        },
      ],
    },
    {
      companyName: 'Valais Hospital (RSV)',
      email: 'jobs@hopitalvs.ch',
      description: 'Leading hospital center providing acute and specialized medical care in Valais.',
      canton: 'VS',
      address: 'Avenue du Grand-Champsec 80 1950 Sion',
      profilePictureUrl: 'https://agenda.science-valais.ch/uploads/thumbs_logo/bf/bfeb34bf7c464e36f0767d9d472f87d8.png',
      companySize: 5500,
      jobs: [
        {
          title: 'Patient Reception & Admissions Assistant',
          description: 'Greet emergency room patients and manage administrative check-ins during evenings and weekends.',
          diplomas: ['apprenticeship'],
          contractTime: null,
          role: 'assistant',
          industry: 'healthcare',
          perks: ['ag', 'mealVouchers'],
          languages: ['french', 'german'],
          holidays: 25,
          maternityLeave: 16,
          paternityLeave: 2,
          workloadPercent: 30,
          salary: 19200.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'HR Administrative Assistant Intern',
          description: 'Maintain employee records and assist with nursing shift scheduling.',
          diplomas: ['bachelor'],
          contractTime: 6,
          role: 'intern',
          industry: 'healthcare',
          perks: ['mealVouchers'],
          languages: ['french'],
          holidays: 20,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 80,
          salary: 34800.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'Medical Logistics & Inventory Clerk',
          description: 'Receive, inspect, and distribute medical supplies throughout Sion Hospital.',
          diplomas: ['apprenticeship'],
          contractTime: 3,
          role: 'unknown',
          industry: 'healthcare',
          perks: ['mealVouchers'],
          languages: ['french'],
          holidays: 20,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 50,
          salary: 25200.0,
          predictedSalary: null,
          visible: true,
        },
      ],
    },
    {
      companyName: 'Grand-Pont Bistro & Restaurant',
      email: 'jobs@grandpont.ch',
      description: 'Traditional restaurant in historic downtown Sion serving Valais specialties.',
      canton: 'VS',
      address: 'Rue du Grand-Pont 6, 1950 Sion',
      profilePictureUrl: 'https://grand-pont.ch/wp-content/uploads/2025/02/BrasserieDuGrandPont_Plats_Thibautlampe_WebRes-21-683x1024.jpg',
      companySize: 20,
      jobs: [
        {
          title: 'Terrace Server (Weekend)',
          description: 'Serve tables and patio areas during peak hours and local festivals.',
          diplomas: ['apprenticeship'],
          contractTime: 4,
          role: 'unknown',
          industry: 'hospitality',
          perks: ['mealVouchers'],
          languages: ['french', 'english'],
          holidays: 20,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 40,
          salary: 21600.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'Kitchen Assistant / Dishwasher',
          description: 'Assist kitchen staff with prep work and maintain dishwashing stations.',
          diplomas: ['apprenticeship'],
          contractTime: 3,
          role: 'unknown',
          industry: 'hospitality',
          perks: ['mealVouchers'],
          languages: ['french'],
          holidays: 20,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 50,
          salary: 24000.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'Assistant Floor Manager',
          description: 'Supervise evening dining service and perform end-of-day register closures.',
          diplomas: ['bachelor'],
          contractTime: null,
          role: 'manager',
          industry: 'hospitality',
          perks: ['mealVouchers', 'housingSupport'],
          languages: ['french', 'german', 'english'],
          holidays: 25,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 80,
          salary: 43200.0,
          predictedSalary: null,
          visible: true,
        },
      ],
    },
    {
      companyName: 'Novel-T Software',
      email: 'jobs@novelt.ch',
      description: 'Software solutions and IT innovation company.',
      canton: 'VS',
      address: 'Rte de Peney 2/4, 1214 Vernier',
      profilePictureUrl: 'https://media.licdn.com/dms/image/v2/C4D0BAQFaPPo7wEOV4w/company-logo_200_200/company-logo_200_200/0/1654586514322/novel_t_s_rl_logo?e=2147483647&v=beta&t=VABNXryzijMwNYYocrWe1ZpAWP-82L2uQM0YPGbP8s0',
      companySize: 45,
      jobs: [
        {
          title: 'Mobile Flutter Developer Intern',
          description: 'Design and maintain mobile modules for regional industrial clients.',
          diplomas: ['bachelor', 'master'],
          contractTime: 6,
          role: 'intern',
          industry: 'informationTechnology',
          perks: ['mealVouchers'],
          languages: ['french', 'english'],
          holidays: 25,
          maternityLeave: 16,
          paternityLeave: 3,
          workloadPercent: 100,
          salary: 46800.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'Digital Marketing & Communications Assistant',
          description: 'Manage social media channels, write technical blog posts, and engage community members.',
          diplomas: ['bachelor'],
          contractTime: 6,
          role: 'unknown',
          industry: 'informationTechnology',
          perks: ['housingSupport', 'mealVouchers'],
          languages: ['french', 'english'],
          holidays: 25,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 50,
          salary: 25200.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'QA & Automation Engineer',
          description: 'Write and run automated test suites for web and mobile applications.',
          diplomas: ['bachelor'],
          contractTime: 12,
          role: 'midLevel',
          industry: 'informationTechnology',
          perks: ['ag'],
          languages: ['french', 'english'],
          holidays: 25,
          maternityLeave: 14,
          paternityLeave: 2,
          workloadPercent: 60,
          salary: 36000.0,
          predictedSalary: null,
          visible: true,
        },
        {
          title: 'Junior IT Project Manager',
          description: 'Manage Agile/Scrum delivery and handle communications with regional clients.',
          diplomas: ['master'],
          contractTime: null,
          role: 'manager',
          industry: 'informationTechnology',
          perks: ['mealVouchers', 'ag', 'stockOptions'],
          languages: ['french', 'english', 'german'],
          holidays: 25,
          maternityLeave: 16,
          paternityLeave: 3,
          workloadPercent: 100,
          salary: 70000.0,
          predictedSalary: null,
          visible: true,
        },
      ],
    },
  ];

  const createdJobIds = [];

  for (const emp of employersData) {
    const employerAuth = await auth.createUser({
      email: emp.email,
      password: PASSWORD,
      displayName: emp.companyName,
    });

    await db.collection('users').doc(employerAuth.uid).set({
      companyName: emp.companyName,
      email: emp.email,
      role: 'employer',
      description: emp.description,
      canton: emp.canton,
      address: emp.address,
      profilePictureUrl: emp.profilePictureUrl || null,
      companySize: emp.companySize,
      reviews: [],
      createdAt: new Date(),
    });

    for (const job of emp.jobs) {
      const jobDoc = await db.collection('jobs').add({
        userUuid: employerAuth.uid,
        title: job.title,
        description: job.description,
        diplomas: job.diplomas,
        contractTime: job.contractTime,
        role: job.role,
        industry: job.industry,
        perks: job.perks,
        languages: job.languages,
        holidays: job.holidays,
        maternityLeave: job.maternityLeave,
        paternityLeave: job.paternityLeave,
        workloadPercent: job.workloadPercent,
        salary: job.salary,
        predictedSalary: job.predictedSalary,
        visible: job.visible,
        translations: [],
        createdAt: new Date(),
      });

      createdJobIds.push(jobDoc.id);
    }
  }

  /// APPLICATIONS
  console.log('Creating sample job applications...');
  const sampleApplications = [
    {
      studentIndex: 0,
      jobIndex: 0,
      status: 'reviewing',
    },
    {
      studentIndex: 0,
      jobIndex: 9,
      status: 'accepted',
    },
    {
      studentIndex: 1,
      jobIndex: 6,
      status: 'submitted',
    },
    {
      studentIndex: 2,
      jobIndex: 2,
      status: 'submitted',
    },
    {
      studentIndex: 3,
      jobIndex: 10,
      status: 'rejected',
    },
  ];

  for (const app of sampleApplications) {
    const studentUid = studentUids[app.studentIndex];
    const jobId = createdJobIds[app.jobIndex];
    const appId = `${jobId}_${studentUid}`;

    await db.collection('applications').doc(appId).set({
      jobId: jobId,
      studentUuid: studentUid,
      status: app.status,
      lastUpdated: new Date(),
      createdAt: new Date(),
    });
  }

  console.log('😛 Database successfully seeded!');
  process.exit(0);
}

fillDatabase().catch((error) => {
  console.error('🔥🔥🔥 Error during database seeding:', error);
  process.exit(1);
});