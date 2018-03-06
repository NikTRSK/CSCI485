-- INDEXES
CREATE INDEX jobApplicationJobIdIdx ON "JobApplication" (jobId);
CREATE INDEX jobCategoryIdIdx ON "JobCategory" (categoryId);
CREATE INDEX jobListJobIdIdx ON "JobList" (jobId);
CREATE INDEX numOfAppsIdx ON "JobApplication" (applicationId);
CREATE INDEX replyMessageIdIdx ON "Message" (replyMessageId);
CREATE INDEX toUserIdIdx ON "Message" (toUserId);
CREATE INDEX fromUserIdIdx ON "Message" (fromUserId);
CREATE INDEX empUserIdx ON "Employer" (userId);
CREATE INDEX usrIdx ON "User" (userId);

-- MATERIALIZED VIEWS
SELECT * FROM ApplicantView;
SELECT * FROM msgView;
SELECT * FROM companyApplicationsReceived;
SELECT * FROM marketVacancy;

-- Query-1: Show Employer 90109 (id=90109)’s five recent messages received from other
-- employers. For each message, retrieve the sender’s first name, last name, profile image URL,
-- message content, and message date. Your query should produce data in these columns. Your
-- query should be able to run against another employer by simply replacing employerId 90109.

SELECT usr.firstName "First Name",
			 usr.lastName "Last Name",
			 usr.profilePictureURL "Profile Image URL",
			 msg.message "Message Content",
			 msg.creationDate "Message Date"
FROM "Message" AS msg, "Employer" AS emp, "User" AS usr
WHERE toUserId = 90109 AND emp.userId = fromUserId AND usr.userId = emp.userId
ORDER BY msg.creationDate DESC
LIMIT 5;

-- OUTPUT
-- Unoptimized: execution: 42ms, fetching: 13ms
-- Indexed: execution: 5ms, fetching: 6ms
--          Indexes: fromUserIdIdx, toUserIdIdx, empUserIdx
-- Materialized View didn't provide any optimization
--
--  Paul      | Black    | http://bb6e0156-b9f4-405c-9d9e-968cfde68cee.com | M:509ca233-1fb8-4b9e-9786-83c2bf103f83 | 2017-03-22
--  Paul      | Black    | http://bb6e0156-b9f4-405c-9d9e-968cfde68cee.com | M:4db2c35d-cd5d-4df0-8e8d-b6c48509b2af | 2017-03-08
--  Paul      | Black    | http://bb6e0156-b9f4-405c-9d9e-968cfde68cee.com | M:9c17d0bc-98e8-4dd6-97f6-3908e756270f | 2016-04-16
--  Paul      | Black    | http://bb6e0156-b9f4-405c-9d9e-968cfde68cee.com | M:bd637918-b030-4c45-a7ba-a2356e21cfa2 | 2015-09-30
-- (4 rows)

-- Query-2: Show Employer 90196’s top 5 job listings that receive the highest number of job
-- applications. For each job listing, show all columns in the JobList table except jobId and userId.
-- Your query should produce data in these columns. Your query should be able to run against
-- another employer by simply replacing employerId 90196.

SELECT job.title "Title",
			 job.salary "Salary",
			 job.postDate "Post Date",
			 job.responsibility "Responsibility",
			 job.timeDemand "Time Demand"
FROM "JobList" AS job JOIN
	(
		SELECT job.jobId
	  FROM "JobList" AS job, "JobApplication" AS jobApp
	  WHERE job.userId = 90196 AND job.jobId = jobApp.jobId
	  GROUP BY job.jobId
	  ORDER BY COUNT(job.jobId) DESC
	) AS derived USING (jobId)
LIMIT 5;

 -- OUTPUT
 -- Unoptimized: execution: 17ms, fetching: 17ms
 -- Indexed: execution: 5ms, fetching: 5ms
 --          Indexes: jobListJobIdIdx, jobApplicationJobIdIdx
 -- Materialized View didn't provide any optimization
 --
 -- Sushi Chef              | 259845 | 2016-02-13 | Responsibility:683c7a9f-4f58-4bc0-a05c-23a4b6369831 | Co-op
 -- City Comptroller        | 122115 | 2015-11-23 | Responsibility:cb5c438e-0b8e-4a93-95af-ca08400bd97a | Co-op
 -- Oxidation Engineer      | 287476 | 2015-12-26 | Responsibility:aaabdf4d-738e-4dc2-9512-dc9519c0d09b | Co-op
 -- Chief Financial Officer | 65064  | 2017-10-12 | Responsibility:f680766f-6307-400e-8b02-713469481d43 | Co-op
 -- Rig Supervisor          | 339524 | 2015-07-31 | Responsibility:cc6bc431-b815-447b-bcc5-f9f0d211d202 | Co-op
 -- (5 rows)

-- Query-3: Show Employer 90196’s job applicants for job listing with jobId = 4401. For each job
-- applicant show their chatbot answers associated with their corresponding questions, summary,
-- experience, educations, skills, honors and certificates. With multiple skills for an applicant,
-- concatenate these skills and show as one value for the skill column. The same applies for other
-- fields. Your query should produce data in these columns. Your query should be able to run
-- against another job listing by simply replacing jobId 4401.

CREATE MATERIALIZED VIEW ApplicantView AS
  SELECT
    jobseeker.summary "Summary",
    jobseeker.experience "Experience",
    string_agg(DISTINCT institute.name, ', ') "Education Institute",
    string_agg(DISTINCT skill.skillName, ', ') "Skills",
    string_agg(DISTINCT honor.honorName, ', ') "Honors",
    string_agg(DISTINCT certificate.certificateName, ', ') "Certificates",
    string_agg(DISTINCT chatquestion.question, ', ') "Questions",
    string_agg(DISTINCT chatanswer.answer, ', ') "Answers"
  FROM "JobApplication" jobapp
    JOIN "JobSeeker" jobseeker ON	(jobapp.jobSeekerId = jobseeker.userId)
    JOIN "JobSeekerEducation" JSE ON (jobapp.jobSeekerId = JSE.userId)
    JOIN "Institute" institute ON (institute.instituteId = JSE.instituteId)
    JOIN "JobSeekerSkill" jobseekerskill ON	(jobapp.jobSeekerId = jobseekerskill.userId)
    JOIN "Skill" skill ON (jobseekerskill.skillId = skill.skillId)
    JOIN "JobSeekerHonor" honor ON (jobapp.jobSeekerId = honor.userId)
    JOIN "JobSeekerCertificate" certificate ON (jobapp.jobSeekerId = certificate.userId)
    JOIN "ChatbotAnswer" chatanswer ON (jobapp.applicationId = chatanswer.applicationId)
    JOIN "Chatbot" chatquestion ON (chatanswer.questionId = chatquestion.questionId)
    JOIN "JobList" joblist ON (joblist.userId = 90196)
  WHERE jobapp.jobId = 4401
  GROUP BY jobseeker.summary, jobseeker.experience, joblist.userId; -- Guess we have to put it here or in an aggregate function

-- OUTPUT
-- Unoptimized: execution: 588ms, fetching: 10ms
-- Indexed: execution: 417ms, fetching: 6ms
--          Indexes: jobListJobIdIdx
-- Indexed + Materialized Views: execution: 2ms, fetching: 6ms
--           Materialized View: ApplicantView
--
--                    Summary                    |                   Experience                    |                                                                                Education Institute
--                                      |                                                                                     Skills                                                                                     |
--                                                                                   Honors                                                                                                           |
--                                                          Certificates                                                                                                      |                                    Questions
--               |                                    Answers
-- ----------------------------------------------+-------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------+--------------------------------------------------------------------------------
--  Summary:008e6e7a-5be6-4d6a-af7a-dadd5860f5fc | Experience:c91de04a-6ef9-41c8-aef9-3af4b147282d | East-West University, Istanbul Arel University, St. Anselm College
--                                      | Communication, Conducting Meetings, Defining Performance Standards, Emotional Control, Independent Action, Learning, Meeting Deadlines, Motivation, Proposal Writing, Training | Honor:0c4ef21e-8471-4577-a6e3-5c45b9a92828, Honor:28dfb5a6-0941-49b9-ace2-65fc99525db0, Honor:b2a99536-c2e2-4f2c-8a16-3a6f791c3335                                                                                         | Cert:664d81e5-d203-4873-97cf-3cf5a2e5c456, Cert:9649309e-7c61-46c0-81d3-84dc90147260, Cert:d7f498a2-b4e3-4aa0-a783-cfa43821d2d5                                                                                       | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:9699ee53-c42a-4c29-91d6-bf8722a4d518, A:f6024c38-01c0-4f54-93fd-94973b972599
--  Summary:113da6e4-c1ca-4486-a5ee-db7b6c16da67 | Experience:094173f9-ed8a-468d-b86b-5b90e4ac103a | Buddhist Acamedy of China, University of Arkansas at Pine Bluff, Yantai University
--                                      | Budgeting, Creating New Solutions, Innovation, Team Building                                                                                                                   | Honor:9aa7dc93-316a-44f2-bd62-0c5c2d635112                                                                                                                                                                                 | Cert:1e690af2-1d4f-4687-9e92-e4dfc8019b17
--                                                                                                                                                                            | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:a08a256a-3823-4523-904a-3e3c1b3721f6, A:ec209a9b-1753-4861-8561-62f64909b4b9
--  Summary:551a8acd-7b98-4d64-878a-bb8b05c59512 | Experience:c366a79b-1184-42a6-b2ea-5186b89aa9a7 | Institute of Industrial Electronics Engineering, Universidad de Palermo, University of Baguio
--                                      | Communication, Construction, Customer Service, Problem Solving, Service, Technology                                                                                            | Honor:24de9511-347d-4295-960e-1d0d1f39db94, Honor:e09eef1f-c31e-473e-ba1f-52b21f000d86                                                                                                                                     | Cert:4262ebf9-7e8b-4923-90bb-e7d27d971618, Cert:aa0e8965-62aa-4ccd-9767-64dfc1eec3cd                                                                                                                                  | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:2021105b-7ff2-4c9e-820b-76486ae1763c, A:c4adb475-8324-412e-ac44-5a924050aa45
--  Summary:61ea1763-8f6f-431c-b333-61844c298700 | Experience:19b5ed04-9094-4464-8815-a2f359d7fc21 | Academia Nacional Superior de Orquesta, Chukyo Womens University, South China Construction University
--                                      | Involvement, Screening Calls                                                                                                                                                   | Honor:2dab51d1-d274-42f4-8597-5711dbc4ea42, Honor:9877a9b7-107f-4f55-8042-b2b3b7c6e668, Honor:ae436ddd-17ef-4a8b-9ffe-602579cdc392, Honor:fc362189-8ba5-414a-9161-02640b84d5ac                                             | Cert:0bcc0743-4622-4144-b45c-c27f53ad2106, Cert:53274b57-7940-416f-abd2-5737425dbae1, Cert:5c794214-f008-442e-a314-4810c865f1dc, Cert:6669cf11-2905-4c09-8ec6-36492b0dc684                                            | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:657f2e11-112e-4e89-9865-5e10dd25f29d, A:7e3f1598-1868-4a70-92e4-afc17ae1e309
--  Summary:6588a754-de67-4bc9-9de4-ed74d1c94a23 | Experience:a8661766-d66c-4c37-8b2d-4bafccfe2096 | Universidad Luterana Salvadorena
--                                      | Administrative, Creative Thinking, Financial Report Auditing, Locating Missing Documents/Information, Promotions, Training                                                     | Honor:5d3ccbe6-6893-4075-b386-28b73dbae0be, Honor:77adc250-7c0d-4a10-a414-94d8e89dab5f, Honor:af75c70d-15ba-49a8-815a-ec21a23425ef, Honor:b792d6a0-8d57-4878-b95b-707c8454d7c8                                             | Cert:48f012f8-5e94-4d86-8462-397f6d555ad5, Cert:9d605cc0-00c6-494b-b4f3-91c4afcf1abf, Cert:9fe4f33b-dd0b-4613-858d-c574b8933623, Cert:a32449ad-9287-4dc7-92d2-11cb9cfdfc71                                            | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:0f469839-0c87-4154-8d19-d8c734bd67be, A:7cdbb4b1-2069-4154-b72f-b6dce03f36a7
--  Summary:65cdc77d-4bb6-40da-881b-ccdea08225e4 | Experience:8c0819cd-8cdb-41a4-91b3-a49fa88b2dd2 | Hanshin University, Odessa National Marine University
--                                      | Coaching Individuals, Collaboration, Handling Complaints, Human Resources, Information Search, Monetary Collection, Organizational Management                                  | Honor:01a54b06-ece7-4ea7-aa15-2b8b460f0442                                                                                                                                                                                 | Cert:de11d81d-510a-427f-91ca-56b741e121b8
--                                                                                                                                                                            | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:2e765ac6-ccbf-4e5f-bb3c-9d9a3cf28843, A:eeb49f67-504c-4a0e-b735-ad44899ca479
--  Summary:68bb8ad4-f713-45c9-bf87-afd6a0c613e4 | Experience:024459f9-0b3e-46b2-a4d9-714603c1ad90 | Ecole Nationale SupΘrieure des Telecommunications de Paris, Institut National des Postes et TΘlΘcommunications, Louisiana State University and Agricultural and Mechanical College | Compiling Statistics, Involvement, Reading Volumes                                                                                                                             | Honor:3fbe417e-1e8d-4ee1-a5fc-ce9d4eb244c7, Honor:48594db3-4dbd-4d42-a0f8-a0a492cdf510, Honor:82ef8467-5467-4d31-beed-75a83877bb6b, Honor:84b2bc3c-fc0d-4828-8bca-dbcedaf637e7, Honor:a8051b2f-83c3-447d-9024-6cadea909a41 | Cert:0fb09535-b790-428b-b840-8a2423e9c49a, Cert:4252ccf3-c833-4051-a9b3-55699037db16, Cert:9332b56e-9110-43d1-9467-23048717eae0, Cert:9f54cc1a-c286-4c86-abdf-9add60d156d6, Cert:ca7b0221-bff2-4065-bea0-7a05cddc3253 | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:084a923d-3162-434d-8565-d29b677921e3, A:374bbb9e-c2f1-431e-8320-432e0be1ac28
--  Summary:9f54113a-0166-41e3-9686-4f65290bf292 | Experience:0af21175-1a3b-4134-89c3-e6c9a541a218 | Community College of Denver
--                                      | Accuracy, Updating Files                                                                                                                                                       | Honor:0f0ece67-e558-4cca-ac45-ac15429d3b6a, Honor:172694af-4a7e-4003-a7d5-9696b1b1817d, Honor:97d6e78f-be05-41ae-a965-f9778620100c, Honor:ecb96cda-523c-42db-80ee-c0c4e6bd57fe, Honor:fef5d57b-512a-48dc-be7d-04ab29b60aa3 | Cert:62c840ad-a1b6-4c54-ba28-43f89d315fbe, Cert:be32f640-bd16-4a17-b391-ef03c856b9aa, Cert:ca17e87c-b884-4c02-bf58-21a73775d2f3, Cert:df81e568-879e-4d0f-b969-7e03492f5df2, Cert:e3f197ee-ba9f-4eee-be10-c485aed6d190 | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:340d06a7-8e56-46e3-91b1-299d7d6809e7, A:d1653071-c5c0-430d-927f-cd35e8cf4d74
--  Summary:dbe58c1e-c478-4f3b-877d-21d06b19e8e6 | Experience:1beba618-6654-42bd-bf5c-46502ad7fb7f | Bethel College Mishawaka, Chalmers University of Technology, Universidade Cat≤lica de Petr≤polis
--                                      | Analytical, Emotional Control, Meeting Deadlines, Proposal Writing, Recommendations, Responsibility, Time Management                                                           | Honor:a11449f0-f215-4a49-adf9-76f06d59c332, Honor:ea7ad05c-83f6-461f-be82-5185b8287721, Honor:fe08e07f-4f6b-401f-a4f6-84b8be9590d9                                                                                         | Cert:5d9e50a8-dc3e-47a4-ac6b-0e5b6662627a, Cert:b1e0c1b0-0784-46be-9d29-810cea65932a, Cert:e91c009a-cbba-45b0-b2c4-9c144a392e06                                                                                       | Q:a4c0c413-fd3d-4cc1-9bf1-bd9bc2b7300f?, Q:bafccea1-ec1f-40a6-92a7-430e11a0fb03? | A:cecdce0a-bf58-45d2-8c34-1b4729509f72, A:ed87cdf4-37d0-4cc6-b89b-ed88a5bd2781
-- (9 rows)

-- Query-4: Show user 1’s messages.
-- Show all messages of a user group by message threads. For each message, show both user’s
-- profile picture URL, first name, last name, message content and message date. A message thread
-- starts with a record that has replyMessageId equals -1. Your query should produce data in these
-- columns. Your query should be able to run against another user by simply replacing user 1.
-- (HINT: use recursive sql)

CREATE MATERIALIZED VIEW msgView AS
  WITH RECURSIVE messages AS (
    SELECT messageID, replyMessageID, fromUserID, toUserID, message, creationDate
    FROM "Message"
    WHERE (fromUserID = 1 OR toUserID = 1) AND replyMessageID = -1
    UNION ALL
    SELECT m.messageID, m.replyMessageID, m.fromUserID, m.toUserID, m.message, m.creationDate
    FROM "Message" m
      JOIN messages ON m.replyMessageID = messages.messageID
  )
  SELECT
    messageID "Message ID",
    usrFrom.firstName "Sender First Name",
    usrFrom.lastName "Sender Last Name",
    usrFrom.profilePictureURL "Sender Profile Image URL",
    replyMessageID "Reply ID",
    usrTo.firstName "Receiver First Name",
    usrTo.lastName "Receiver Last Name",
    usrTo.profilePictureURL "Receiver Profile Image URL",
    message "Message Content",
    creationDate "Message Date"
  FROM messages
    JOIN "User" usrFrom ON (usrFrom.userID = messages.fromUserId)
    JOIN "User" usrTo ON (usrTo.userID = messages.toUserId);

-- OUTPUT
-- Unoptimized: execution: 190ms, fetching: 9ms
-- Indexed: execution: 59ms, fetching: 9ms
--          Indexed: usrIdx, fromUserIdIdx, toUserIdIdx
-- Indexed + Materialized Views: execution: 3ms, fetching: 9ms
--           Materialized View: msgView
--
--  Message ID | Sender First Name | Sender Last Name |            Sender Profile Image URL             | Reply ID | Receiver First Name | Receiver Last Name |           Receiver Profile Image URL            |            Message Content
--       | Message Date
-- ------------+-------------------+------------------+-------------------------------------------------+----------+---------------------+--------------------+-------------------------------------------------+----------------------------------------+--------------
--      235866 | Angela            | Lee              | http://395ee3f8-8d72-4685-ae4a-e94b89c33537.com |    72477 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:e41ddc95-8122-4e2e-b47a-92fa4c35436e | 2015-08-04
--       72477 | Angela            | Lee              | http://395ee3f8-8d72-4685-ae4a-e94b89c33537.com |       -1 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:38147767-f559-4442-9052-90941de81c46 | 2016-06-11
--      191304 | Angela            | Lee              | http://395ee3f8-8d72-4685-ae4a-e94b89c33537.com |    72477 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:6b814b03-c80b-4de5-9de2-867a3f07e26c | 2016-01-07
--      140036 | Anthony           | Garza            | http://9a25d338-1e13-446c-868c-2d62e3754aed.com |   140035 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:245548a4-81f7-4d55-87b6-51ed1fcb9bf2 | 2017-07-14
--       76816 | Anthony           | Garza            | http://9a25d338-1e13-446c-868c-2d62e3754aed.com |       -1 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:cf941f0b-0c6c-4433-9a8a-e0148ad49e77 | 2015-12-30
--      140034 | Anthony           | Garza            | http://9a25d338-1e13-446c-868c-2d62e3754aed.com |    76816 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:485899f7-fdd7-454f-a2dc-61e40eb00645 | 2015-06-26
--      147668 | Charles           | Fielding         | http://4209081a-46d4-4efb-884a-238007804046.com |   147667 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:c0e1d832-3deb-4e2c-83c8-5fc125e5819b | 2015-11-30
--       75992 | Charles           | Fielding         | http://4209081a-46d4-4efb-884a-238007804046.com |       -1 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:b2ecf7cb-5665-4be7-871c-d9bbdc93f155 | 2015-05-30
--      147666 | Charles           | Fielding         | http://4209081a-46d4-4efb-884a-238007804046.com |    75992 | Rachel              | Desoto             | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com | M:6428a590-2a3a-4c51-8457-86e32f8d6d43 | 2015-11-24
--       22701 | Rachel            | Desoto           | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com |       -1 | Lindsey             | Alexander          | http://1704b243-2f9b-407b-86e5-188ceac31b6b.com | M:e20be945-94c1-4290-99ca-3723be938d3c | 2015-09-27
--      235868 | Carlos            | Yard             | http://116e07a9-d9f6-4f82-8a4f-4cb79f28580a.com |   235867 | Thomas              | Brown              | http://dda04bd7-a9ec-4b45-b842-6ddc1eabad59.com | M:3d3b3858-b4cd-4b3d-ad52-5486ccc1e698 | 2016-04-16
--      140035 | Alicia            | Westra           | http://a6bc1051-53a6-4301-bfa0-eea6017e1db7.com |   140034 | Anna                | Loring             | http://6f440e7c-1a2f-4e2e-b109-3ead2c15d9d7.com | M:2dcafa2b-d6af-418e-8fe5-3ffbd35de70c | 2015-03-24
--      191306 | Roger             | Salter           | http://a4260514-d75d-4b3b-b4db-11162dc33662.com |   191305 | Clarence            | Jones              | http://4da524ba-2618-41f7-b01e-4bad59afbe9b.com | M:fd6d97c1-8158-49c2-b3a5-33a95165d65b | 2015-07-26
--      191305 | Robert            | Phelan           | http://88a2f27f-bafe-47df-8ecf-a154e33f0102.com |   191304 | Abram               | Pilon              | http://6507da5b-95f9-4f28-b2de-f71257886834.com | M:645ae96d-7363-4e59-8609-c05c5333b415 | 2015-07-11
--      235867 | Scott             | Byrd             | http://416bfc15-b727-4a8e-bb38-401b821a9567.com |   235866 | Elizabeth           | Knopp              | http://70709c62-2cb6-4637-99ae-857241822bbb.com | M:60a7fc52-9387-4548-9d58-4f8e497f5d11 | 2015-04-01
--      147667 | Faye              | Robinson         | http://3e853dae-7a66-4fe4-bea8-c61e557144c2.com |   147666 | William             | McNeil             | http://e8fb11fb-2714-4b86-aadf-ee6c4a8cf265.com | M:802a3b36-f617-48ed-9efa-2aa0c1feaa73 | 2015-11-30
--       45008 | Rachel            | Desoto           | http://9e3d4e25-fa2a-4e96-a982-14a39079bc7b.com |       -1 | David               | Schaefer           | http://3d55a164-28c3-4b39-9ff3-c95cfe095002.com | M:9e514a79-093c-4637-a384-9263c5f4689e | 2015-09-08
-- (17 rows)

-- Query-5: Retrieve top 5 companies with more than 100 job applications from 2015 to 2018
-- sorted by the number of received job applications in descending order. Your query should
-- produce data in these columns.

CREATE MATERIALIZED VIEW companyApplicationsReceived AS
  SELECT *
    FROM
  (
    SELECT
    companyName             "Company Name",
    website                 "Company Website",
    COUNT(JA.applicationID) "Number of Applications Received"
    FROM "Company" C
    JOIN "Employment" E USING (companyID)
    JOIN "JobList" JL USING (userID)
    JOIN "JobApplication" JA USING (jobID)
    WHERE applyDate BETWEEN to_date('2015-01-01', 'YYYY-MM-DD') AND to_date('2018-12-31', 'YYYY-MM-DD')
    GROUP BY companyName, website
    ORDER BY "Number of Applications Received" DESC
  ) calc
  WHERE "Number of Applications Received" > 100
  LIMIT 5;

-- OUTPUT
-- Unoptimized: execution: 814ms, fetching: 10ms
-- Indexed: execution: 735ms, fetching: 4ms
--          Indexes: numOfAppsIdx
-- Indexed + Materialized view: execution: 3ms, fetching: 4ms
--          Materialized View: companyApplicationsReceived
--
--   Company Name   |   Company Website   | Number of Applications Received
-- -----------------+---------------------+---------------------------------
--  Helios Air      | nanohealthcures.com |                            1352
--  Harvest Foods   | pamleblanc.com      |                            1334
--  Als Auto Parts  | antijonru.com       |                            1280
--  Pauls Food Mart | gwsoadi.com         |                            1246
--  Hanover Shoe    | bushwhackerbags.com |                            1234
-- (5 rows)


-- Query-6: Retrieve the top 5 market vacancy of job categories in 2017 sorted by market vacancy
-- in descending order. The market vacancy of a job category is defined by (# of job listing in a
-- category / # of job applications in a category). Your query should produce data in these columns.

CREATE MATERIALIZED VIEW marketVacancy AS
  SELECT "Category Name", "Market Vacancy"
  FROM
  (
    SELECT categoryId, (CAST ("JobCount" AS FLOAT) /  CAST ("AppCount" AS FLOAT)) AS "Market Vacancy"
    FROM
    (
      -- # of job listings in a category
      SELECT COUNT(jobId) "JobCount", categoryId
      FROM "JobCategory" jc
        JOIN "JobListCategory" jlc USING (categoryId)
        JOIN "JobList" jl USING (jobId)
      WHERE jl.postDate BETWEEN to_date('2017-01-01', 'YYYY-MM-DD') AND to_date('2017-12-31', 'YYYY-MM-DD')
      GROUP BY categoryId
    ) listingsCount
    JOIN
    (
      -- # of job applications in a category
      SELECT COUNT(applicationId) "AppCount", categoryId
      FROM "JobListCategory" jlc
        JOIN "JobApplication" ja USING (jobId)
        JOIN "JobCategory" jc USING (categoryId)
        JOIN "JobList" jl USING (jobId)
      WHERE ja.applyDate BETWEEN to_date('2017-01-01', 'YYYY-MM-DD') AND to_date('2017-12-31', 'YYYY-MM-DD')
      GROUP BY categoryId
    ) applicationsCount
    USING (categoryId)
  ) vacancy
  JOIN
  (
    SELECT categoryId, categoryName AS "Category Name"
    FROM "JobCategory"
  ) catNames USING (categoryId)
  ORDER BY "Market Vacancy" DESC
  LIMIT 5;

-- OUTPUT
-- Unoptimized: execution: 174ms, fetching: 9ms
-- Indexed: execution: 162ms, fetching: 4ms
--          Indexes:
-- Indexed + Materialized Views: execution: 3ms, fetching: 4ms
--           Materialized View: marketVacancy
--
--                          Category Name                         |  Market Vacancy
-- ---------------------------------------------------------------+-------------------
--  Radiologists                                                  |                 1
--  Executive Secretaries and Executive Administrative Assistants |               0.5
--  Shampooers                                                    | 0.428571428571429
--  Special Effects Artists and Animators                         | 0.363636363636364
--  Judicial Law Clerks                                           | 0.285714285714286
-- (5 rows)