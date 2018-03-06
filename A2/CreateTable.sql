CREATE TABLE "User" (
  userID            BIGINT,
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
  PRIMARY KEY (userID)
);

-- COPY "Chatbot" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\Chatbot.csv' WITH (FORMAT CSV);
-- COPY "ChatbotAnswer" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\ChatbotAnswer.csv' WITH (FORMAT CSV);
-- COPY "Company" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\Company.csv' WITH (FORMAT CSV);
-- COPY "Employer" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\Employer.csv' WITH (FORMAT CSV);
-- COPY "Employment" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\Employment.csv' WITH (FORMAT CSV);
-- COPY "Institute" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\Institute.csv' WITH (FORMAT CSV);
-- COPY "JobApplication" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobApplication.csv' WITH (FORMAT CSV);
-- COPY "JobCategory" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobCategory.csv' WITH (FORMAT CSV);
-- COPY "JobList" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobList.csv' WITH (FORMAT CSV);
-- COPY "JobListCategory" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobListCategory.csv' WITH (FORMAT CSV);
-- COPY "JobSeeker" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobSeeker.csv' WITH (FORMAT CSV);
-- COPY "JobSeekerCategory" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobSeekerCategory.csv' WITH (FORMAT CSV);
-- COPY "JobSeekerCertificate" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobSeekerCertificate.csv' WITH (FORMAT CSV);
-- COPY "JobSeekerEducation" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobSeekerEducation.csv' WITH (FORMAT CSV);
-- COPY "JobSeekerHonor" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobSeekerHonor.csv' WITH (FORMAT CSV);
-- COPY "JobSeekerSkill" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\JobSeekerSkill.csv' WITH (FORMAT CSV);
-- COPY "Message" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\Message.csv' WITH (FORMAT CSV);
-- COPY "Skill" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\Skill.csv' WITH (FORMAT CSV);
-- COPY "User" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\User.csv' WITH (FORMAT CSV);
-- COPY "User" from 'C:\Users\Nick\Documents\_Code\CSCI485\A2\data\User.csv' WITH (FORMAT CSV );
