
SQL Database Management and Design Project
UNIVERSITY DATABASE 

## Target
Design the university database which is one possible data model that describes the below set of requirements.

## The University Database Requirements:

- Here is a statement of the data requirements for a product to support the registration of and provide help to students of a fictitious e-learning university.

- An e-learning university needs to keep details of its students and staff, the courses that it offers and the students who study its courses. The university is administered in four geographical regions (England, Scotland, Wales and Northern Ireland).

- Information about each student should be initially recorded at registration. This includes the student’s identification number issued at the time, name, year of registration and the region in which the student is located. A student is not required to enroll in any courses at registration; enrollment in a course can happen at a later time.

- Information recorded for each member of the tutorial and counseling staff must include the staff number, name and region in which he or she is located. Each staff member may act as a counselor to one or more students, and may act as a tutor to one or more students on one or more courses. It may be the case that, at any particular point in time, a member of staff may not be allocated any students to tutor or counsel.

- Each student has one counselor, allocated at registration, who supports the student throughout his or her university career. A student is allocated a separate tutor for each course in which he or she is enrolled. A staff member may only counsel or tutor a student who is resident in the same region as that staff member.

- Each course that is available for study must have a course code, a title and a value in terms of credit points. A course is either a 15-point course or a 30-point course. A courseneed not have any students enrolled in it (such as a course that has just been written and offered for study).

- Students are constrained in the number of courses they can be enrolled in at any one time. They may not take courses simultaneously if their combined points total exceeds 180 points.

University Registration Data Model is according to the Crow's Food model by using Draw.io. The model has several parts, beginning with an ERD and followed by a written description of entity types, constraints, and assumptions.
