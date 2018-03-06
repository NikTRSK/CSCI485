\connect postgres
DROP DATABASE IF EXISTS db_paragon;
CREATE DATABASE db_paragon;
\connect db_paragon
SET CLIENT_ENCODING TO 'utf8';
CREATE TABLE "User" (
  userId            BIGINT,
  phone             VARCHAR(12),
  email             VARCHAR(50),
  profilePictureURL VARCHAR(100),
  firstName         VARCHAR(20),
  lastName          VARCHAR(20),
  streetAddress     VARCHAR(100),
  city              VARCHAR(30),
  state             VARCHAR(30),
  country           VARCHAR(100),
  zipcode           VARCHAR(10),
  PRIMARY KEY (userId)
);

CREATE TABLE "Message" (
  messageId 				BIGINT,
  fromUserId 				BIGINT,
  toUserId  				BIGINT,
  replyMessageId  	BIGINT,
	message  					VARCHAR(200),
	creationDate  		DATE,
	PRIMARY KEY (messageId),
	FOREIGN KEY (fromUserId) REFERENCES "User" (userId),
	FOREIGN KEY (toUserId) REFERENCES "User" (userId)
);

CREATE TABLE "JobSeeker" (
	userId						BIGINT,
	summary						VARCHAR(500),
	isRelocationOK		BOOLEAN,
	experience				VARCHAR(400),
	premiumLevel			INT,
	PRIMARY KEY (userId),
	FOREIGN KEY (userId) REFERENCES "User" (userId)
);

CREATE TABLE "Institute" (
	instituteId				BIGINT,
	name							VARCHAR(300),
	PRIMARY KEY (instituteId)
);

CREATE TABLE "JobSeekerEducation" (
	userId						BIGINT,
	instituteId				BIGINT,
	startDate					DATE,
	endDate						DATE,
	degree						VARCHAR(100),
	PRIMARY KEY (userId, instituteId),
	FOREIGN KEY (userId) REFERENCES "User" (userId),
	FOREIGN KEY (instituteId) REFERENCES "Institute" (instituteId)
);

CREATE TABLE "Skill" (
	skillId						BIGINT,
	skillName					VARCHAR(50),
	PRIMARY KEY (skillId)
);

CREATE TABLE "JobSeekerSkill" (
	userId						BIGINT,
	skillId						BIGINT,
	PRIMARY KEY (userId, skillId),
	FOREIGN KEY (userId) REFERENCES "User" (userId),
	FOREIGN KEY (skillId) REFERENCES "Skill" (skillId)
);

CREATE TABLE "JobCategory" (
	categoryId				BIGINT,
	categoryName			VARCHAR(100),
	PRIMARY KEY (categoryId)
);

CREATE TABLE "JobSeekerCategory" (
	userId						BIGINT,
	categoryId				BIGINT,
	PRIMARY KEY (userId, categoryId),
	FOREIGN KEY (userId) REFERENCES "User" (userId),
	FOREIGN KEY (categoryId) REFERENCES "JobCategory" (categoryId)
);

CREATE TABLE "JobSeekerHonor" (
	userId						BIGINT,
	honorName					VARCHAR(50),
	PRIMARY KEY (userId, honorName),
	FOREIGN KEY (userId) REFERENCES "User" (userId)
);

CREATE TABLE "JobSeekerCertificate" (
	userId						BIGINT,
	certificateName		VARCHAR(50),
	PRIMARY KEY (userId, certificateName),
	FOREIGN KEY (userId) REFERENCES "User" (userId)
);

CREATE TABLE "Employer" (
	userId						BIGINT,
	position					VARCHAR(100),
	PRIMARY KEY (userId),
	FOREIGN KEY (userId) REFERENCES "User" (userId)
);

CREATE TABLE "JobList" (
	jobId							BIGINT,
	userId						BIGINT,
	title							VARCHAR(100),
	salary						VARCHAR(20),
	postDate					DATE,
	responsibility		VARCHAR(500),
	timeDemand				VARCHAR(20),
	PRIMARY KEY (jobId),
	FOREIGN KEY (userId) REFERENCES "User" (userId)
);

CREATE TABLE "JobListCategory" (
	jobId							BIGINT,
	categoryId				BIGINT,
	PRIMARY KEY (jobId, categoryId),
	FOREIGN KEY (jobId) REFERENCES "JobList" (jobId),
	FOREIGN KEY (categoryId) REFERENCES "JobCategory" (categoryId)
);

CREATE TABLE "Chatbot" (
	questionId				BIGINT,
	userId						BIGINT,
	question					VARCHAR(200),
	PRIMARY KEY (questionId),
	FOREIGN KEY (userId) REFERENCES "User" (userId)
);

CREATE TABLE "Company" (
	companyId					BIGINT,
	companyName				VARCHAR(50),
	socialMediaHandle	VARCHAR(150),
	summary						VARCHAR(500),
	logo							VARCHAR(100),
	companySize				VARCHAR(20),
	website						VARCHAR(60),
	PRIMARY KEY (companyId)
);

CREATE TABLE "JobApplication" (
	applicationId			BIGINT,
	jobSeekerId				BIGINT,
	jobId							BIGINT,
	applyDate					DATE,
	PRIMARY KEY (applicationId),
	FOREIGN KEY (jobSeekerId) REFERENCES "User" (userId),
	FOREIGN KEY (jobId) REFERENCES "JobList" (jobId)
);

CREATE TABLE "ChatbotAnswer" (
	applicationId			BIGINT,
	questionId				BIGINT,
	answer						VARCHAR(300),
	PRIMARY KEY (applicationId, questionId),
	FOREIGN KEY (applicationId) REFERENCES "JobApplication" (applicationId),
	FOREIGN KEY (questionId) REFERENCES "Chatbot" (questionId)
);

CREATE TABLE "Employment" (
	companyId					BIGINT,
	userId						BIGINT,
	PRIMARY KEY (companyId, userId),
	FOREIGN KEY (companyId) REFERENCES "Company" (companyId),
	FOREIGN KEY (userId) REFERENCES "User" (userId)
);

COPY "User" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\User.csv' WITH (FORMAT CSV);
COPY "Message" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\Message.csv' WITH (FORMAT CSV);
COPY "JobSeeker" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobSeeker.csv' WITH (FORMAT CSV);
COPY "Institute" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\Institute.csv' WITH (FORMAT CSV);
COPY "JobSeekerEducation" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobSeekerEducation.csv' WITH (FORMAT CSV);
COPY "Skill" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\Skill.csv' WITH (FORMAT CSV);
COPY "JobSeekerSkill" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobSeekerSkill.csv' WITH (FORMAT CSV);
COPY "JobCategory" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobCategory.csv' WITH (FORMAT CSV);
COPY "JobSeekerCategory" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobSeekerCategory.csv' WITH (FORMAT CSV);
COPY "JobSeekerHonor" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobSeekerHonor.csv' WITH (FORMAT CSV);
COPY "JobSeekerCertificate" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobSeekerCertificate.csv' WITH (FORMAT CSV);
COPY "Employer" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\Employer.csv' WITH (FORMAT CSV);
COPY "JobList" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobList.csv' WITH (FORMAT CSV);
COPY "JobListCategory" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobListCategory.csv' WITH (FORMAT CSV);
COPY "Chatbot" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\Chatbot.csv' WITH (FORMAT CSV);
COPY "Company" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\Company.csv' WITH (FORMAT CSV);
COPY "JobApplication" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\JobApplication.csv' WITH (FORMAT CSV);
COPY "ChatbotAnswer" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\ChatbotAnswer.csv' WITH (FORMAT CSV);
COPY "Employment" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\Employment.csv' WITH (FORMAT CSV);