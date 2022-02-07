

--SQL DBMD 
--UNIVERSITY DATABASE PROJECT 

/* 

Design the university database which is one possible data model that describes the below set of requirements.

The University Database Requirements:

Here is a statement of the data requirements for a product to support the registration of and provide help to students of a fictitious e-learning university.

An e-learning university needs to keep details of its students and staff, the courses that it offers and the students who study its courses. The university is administered in four geographical regions (England, Scotland, Wales and Northern Ireland).

Information about each student should be initially recorded at registration. This includes the student’s identification number issued at the time, name, year of registration and the region in which the student is located. A student is not required to enroll in any courses at registration; enrollment in a course can happen at a later time.

Information recorded for each member of the tutorial and counseling staff must include the staff number, name and region in which he or she is located. Each staff member may act as a counselor to one or more students, and may act as a tutor to one or more students on one or more courses. It may be the case that, at any particular point in time, a member of staff may not be allocated any students to tutor or counsel.

Each student has one counselor, allocated at registration, who supports the student throughout his or her university career. A student is allocated a separate tutor for each course in which he or she is enrolled. A staff member may only counsel or tutor a student who is resident in the same region as that staff member.

Each course that is available for study must have a course code, a title and a value in terms of credit points. A course is either a 15-point course or a 30-point course. A courseneed not have any students enrolled in it (such as a course that has just been written and offered for study).

Students are constrained in the number of courses they can be enrolled in at any one time. They may not take courses simultaneously if their combined points total exceeds 180 points.

University Registration Data Model is according to the Crow's Food model by using Draw.io. The model has several parts, beginning with an ERD and followed by a written description of entity types, constraints, and assumptions.


*/


--CREATE DATABASE

CREATE DATABASE university
USE university

--///////////////////////////////////////////


--CREATE TABLES 

CREATE TABLE region
(
	region_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	region_name VARCHAR(50) NOT NULL,
	CONSTRAINT ch_region CHECK (region_name IN ('England', 'Scotland', 'Wales','Northern Ireland') )
)

CREATE TABLE staff
(
	staff_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	staff_first_name VARCHAR(50) NOT NULL,
	staff_last_name VARCHAR(50) NOT NULL,
	region_id INT  NOT NULL,
	
	CONSTRAINT fk_region FOREIGN KEY (region_id) REFERENCES region(region_id)
)

CREATE TABLE student
(
	student_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	student_first_name VARCHAR(50) NOT NULL,
	student_last_name VARCHAR(50) NOT NULL,
	registiration_date DATE NOT NULL,
	region_id INT  NOT NULL,
	counselor_id INT NOT NULL,
	CONSTRAINT fk_region2 FOREIGN KEY (region_id) REFERENCES region(region_id),
	CONSTRAINT fk_staff FOREIGN KEY (counselor_id) REFERENCES staff(staff_id)
)

CREATE TABLE courses
(
	course_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	course_title VARCHAR(50) NOT NULL,
	credit INT NOT NULL
)

ALTER TABLE courses
ADD CONSTRAINT ch_credit CHECK (credit IN (15,30) )

CREATE TABLE coursebystaff
(
	coursebystaff_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	course_id INT  NOT NULL,
	staff_id INT  NOT NULL,
	CONSTRAINT fk_staff2 FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
	CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES courses(course_id)
)

CREATE TABLE enrollment
(
	coursebystaff_id INT NOT NULL,
	student_id INT NOT NULL,
	PRIMARY KEY (coursebystaff_id, student_id),
	CONSTRAINT fk_coursebystaff FOREIGN KEY (coursebystaff_id) REFERENCES coursebystaff(coursebystaff_id),
	CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES student(student_id)
)

--///////////////////////////////////////////



--INSERT VALUES TO TABLES

INSERT INTO region
VALUES ('England'), ('Scotland'),('Wales'),('Northern Ireland');

INSERT INTO courses
VALUES ('Fine Arts',15), ('German',15),('Chemistry',30),('French',30),('Physics',30),('History',30),('Music',30),('Psychology',30),('Biology',	15);

INSERT INTO staff
VALUES		('Neil','Mango',2),
			('Harry','Smith',1),
			('October','Lime',3),
			('Ross','Island',2),
			('Kellie','Pear',1),
			('Victor','Fig',3),
			('Yavette','Berry',4),
			('Tom','Garden',4),
			('Margeret','Nolan',1);

INSERT INTO student
VALUES		('Alec','Hunter','2020-05-12', 3,3),
			('Bronwin','Blueberry','2020-05-12',2,4),
			('Charlie','Apricot','2020-05-12',1,2),
			('Ursula','Douglas','2020-05-12',2,1),
			('Zorro','Apple','2020-05-12',1,5),
			('Debbie','Orange','2020-05-12',3,6);

INSERT INTO coursebystaff
VALUES		(1,1),(2,2),(3,9),(4,5),(4,9),(5,2),(5,5),(9,7);
			
INSERT INTO enrollment
VALUES (1,1)
INSERT INTO enrollment
VALUES (1,2)


select * from coursebystaff JOIN courses ON coursebystaff.course_id= courses.course_id
JOIN staff ON coursebystaff.staff_id = staff.staff_id

SELECT * FROM student

--///////////////////////////////////////////


--CONSTRAINTS

--1. Students are constrained in the number of courses they can be enrolled in at any one time.
--	 They may not take courses simultaneously if their combined points total exceeds 180 points.

CREATE FUNCTION dbo.fn_student_can_add_course (@student_id INT)

RETURNS INT
AS
BEGIN
	DECLARE @total_credits INT
	DECLARE @result INT

	SELECT @total_credits = SUM(courses.credit)
	FROM coursebystaff 
		JOIN courses ON coursebystaff.course_id = courses.course_id
		JOIN enrollment ON coursebystaff.coursebystaff_id = enrollment.coursebystaff_id
	WHERE enrollment.student_id = @student_id

	IF @total_credits <= 180
		SET @result = 1
	ELSE
		SET @result = 0

	RETURN  @result
END

ALTER TABLE enrollment
ADD CONSTRAINT chk_credit CHECK (dbo.fn_student_can_add_course (enrollment.student_id)=1);

--select dbo.fn_student_can_add_course (1)

--///////////////////////////////////////////


--2. The student's region and the counselor's region must be the same.

CREATE FUNCTION dbo.region_check (@student_id INT, @staff_id INT)

RETURNS INT
AS
BEGIN
	DECLARE @student_region_id INT
	DECLARE @staff_region_id INT
	DECLARE @result INT

	SELECT @staff_region_id = region.region_id
	FROM staff 
		JOIN region ON staff.region_id = region.region_id
	WHERE staff.staff_id = @staff_id 

	SELECT @student_region_id = region.region_id
	FROM student 
		JOIN region ON student.region_id = region.region_id
	WHERE student.student_id = @student_id

	IF @staff_region_id = @student_region_id
		SET @result = 1
	ELSE
		SET @result = 0

	RETURN @result 
	
END

ALTER TABLE student
ADD CONSTRAINT chk_region CHECK (dbo.region_check (student_id ,counselor_id )=1);


--///////////////////////////////////////////

--ADDITIONALLY TASKS


--1. Test the credit limit constraint.
--Add more courses for a student to fill 180 credit limit(an error expected)
INSERT INTO courses
VALUES ('Math',30), ('Music',30),('French History',30),('Robotics',30)

INSERT INTO coursebystaff
VALUES		(10,9),(11,5),(12,2),(13,2);

--fill until 180 credits for student ID 3
INSERT INTO enrollment
VALUES (9,3),(10,3),(11,3),(12,3),(6,3),(4,3)

--Add an extra course that can cause check constraint fail
INSERT INTO enrollment
VALUES (3,3)
/*
OUTPUT : 
Msg 547, Level 16, State 0, Line 218
The INSERT statement conflicted with the CHECK constraint "chk_credit". The conflict occurred in database "university", table "dbo.enrollment", column 'student_id'.
The statement has been terminated.
*/

--///////////////////////////////////////////

--2. Test that you have correctly defined the constraint for the student counsel's region. (an error expected) 
--Insert staff ID 1 whose region is 1 but student region is 3
INSERT INTO student
VALUES		('Ali','Veli','2020-05-12', 3,1);

/*
OUTPUT:
Msg 547, Level 16, State 0, Line 234
The INSERT statement conflicted with the CHECK constraint "chk_region". The conflict occurred in database "university", table "dbo.student".
The statement has been terminated.
*/

--///////////////////////////////////////////



--3. Try to set the credits of the History course to 20. (an error expected)

UPDATE courses
SET credit = 20
WHERE course_title='History'

/*
OUTPUT:
Msg 547, Level 16, State 0, Line 252
The UPDATE statement conflicted with the CHECK constraint "ch_credit". The conflict occurred in database "university", table "dbo.courses", column 'credit'.
The statement has been terminated.
*/

--///////////////////////////////////////////



--4. Try to set the credits of the Fine Arts course to 30. 
UPDATE courses
SET credit = 15
WHERE course_title='Fine Arts'

--NO ERROR

--///////////////////////////////////////////



--5. Debbie Orange wants to enroll in Chemistry instead of German.

INSERT INTO enrollment
VALUES ((SELECT student_id FROM student WHERE student_first_name='Debbie' and student_last_name='Orange'),
		( 
			SELECT coursebystaff_id
			FROM coursebystaff JOIN courses ON coursebystaff.course_id=courses.course_id
			WHERE course_title='German'
		)
		)
--NO ERROR

--///////////////////////////////////////////


--6. Try to set Tom Garden as counsel of Alec Hunter (an error expected)
UPDATE student
SET counselor_id= (SELECT staff_id FROM staff WHERE staff_first_name='Tom' and staff_last_name='Garden')
WHERE student_first_name='Alec' and student_last_name='Hunter'
/*
OUTPUT:
Msg 547, Level 16, State 0, Line 286
The UPDATE statement conflicted with the CHECK constraint "chk_region". The conflict occurred in database "university", table "dbo.student".
The statement has been terminated.
*/

--///////////////////////////////////////////


--7. Swap counselors of Ursula Douglas and Bronwin Blueberry.

DECLARE @temp  INT

SET @temp= (SELECT counselor_id FROM student WHERE student_first_name='Ursula' and student_last_name='Douglas')

UPDATE student
SET counselor_id= (SELECT counselor_id FROM student WHERE student_first_name='Bronwin' and student_last_name='Blueberry')
WHERE student_first_name='Ursula' and student_last_name='Douglas'

UPDATE student
SET counselor_id= @temp 
WHERE student_first_name='Bronwin' and student_last_name='Blueberry'

--///////////////////////////////////////////


--8. Remove a staff member from the staff table.
--	 If an error, we must update the reference rules for the relevant foreign key.
DELETE staff
WHERE staff_id=8

--NO ERROR



 


















