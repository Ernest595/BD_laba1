CREATE TABLE `group` (
    id INT PRIMARY KEY,
    shifr VARCHAR(10) NOT NULL,        
    course INT CHECK (course BETWEEN 1 AND 4) 
);


CREATE TABLE student (
    id INT PRIMARY KEY,
    surname VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    gender VARCHAR(10) CHECK (gender IN ('мужской', 'женский')),
    birth_date DATE,
    group_id INT,
    FOREIGN KEY (group_id) REFERENCES `group`(id)
);


CREATE TABLE subject (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    report_type ENUM('rating', 'exam', 'paper') NOT NULL
);



CREATE TABLE marks (
    stud_id INT,
    subj_id INT,
    semester INT CHECK (semester BETWEEN 1 AND 8),
    grade INT CHECK (grade BETWEEN 2 AND 5),
    PRIMARY KEY (stud_id, subj_id, semester),
    FOREIGN KEY (stud_id) REFERENCES student(id),
    FOREIGN KEY (subj_id) REFERENCES subject(id)
);


-- 1. 
SELECT s.*
FROM student s
JOIN `group` g ON s.group_id = g.id
WHERE g.course = 3;

-- 2. 
SELECT g.*
FROM `group` g
JOIN student s ON s.group_id = g.id
GROUP BY g.id
HAVING COUNT(s.id) >= 10;

-- 3. 
SELECT sub.name
FROM subject sub
JOIN marks m ON sub.id = m.subj_id
WHERE sub.report_type = 'exam' AND m.semester = 4
GROUP BY sub.id, sub.name
HAVING AVG(m.grade) > 3.5;

-- 4. 
SELECT s.*
FROM student s
JOIN `group` g ON s.group_id = g.id
WHERE g.course IN (2,4) 
AND s.id IN (
    SELECT m.stud_id
    FROM marks m
    WHERE m.semester = 3 AND m.grade = 5
    GROUP BY m.stud_id
    HAVING COUNT(DISTINCT m.subj_id) = (SELECT COUNT(*) FROM subject WHERE report_type = 'exam')
)
LIMIT 10;

-- 5. 
SELECT DISTINCT sub.name
FROM subject sub
JOIN marks m ON sub.id = m.subj_id
JOIN student s ON m.stud_id = s.id
JOIN `group` g ON s.group_id = g.id
WHERE g.course IN (3,4) AND sub.report_type = 'paper';

-- 6. 
SELECT m.semester
FROM student s
JOIN `group` g ON s.group_id = g.id
JOIN marks m ON s.id = m.stud_id
WHERE g.shifr = 'ИТПМ-124' AND m.report_type = 'exam'
GROUP BY m.semester
HAVING COUNT(DISTINCT s.id) >= 3 AND AVG(m.grade) > 4.5;

-- 7. 
SELECT s.*
FROM student s
JOIN `group` g ON s.group_id = g.id
WHERE s.gender = 'мужской' AND g.course IN (2,4)
ORDER BY s.birth_date ASC
LIMIT 5;

-- 8. 
SELECT sub.name
FROM subject sub
JOIN marks m ON sub.id = m.subj_id
JOIN student s ON m.stud_id = s.id
JOIN `group` g ON s.group_id = g.id
WHERE g.shifr = 'ИТПМ-124'
GROUP BY sub.id, sub.name
HAVING AVG(m.grade) BETWEEN 3.0 AND 4.0;

-- 9. 
SELECT s.surname
FROM student s
JOIN `group` g ON s.group_id = g.id
WHERE s.id NOT IN (
    SELECT m.stud_id
    FROM marks m
    JOIN subject sub ON m.subj_id = sub.id
    WHERE sub.name = 'Базы данных' AND m.semester = 3 AND m.grade >= 2
);

-- 10. 
SELECT s.*
FROM student s
JOIN marks m ON s.id = m.stud_id
JOIN subject sub ON m.subj_id = sub.id
WHERE sub.name = 'Защита информации' AND m.semester = 4;

-- 11. 
SELECT s.*
FROM student s
WHERE s.id IN (
    SELECT s2.id
    FROM student s2
    LEFT JOIN marks m ON s2.id = m.stud_id AND m.report_type = 'exam'
    GROUP BY s2.id
    HAVING COUNT(CASE WHEN m.grade IS NULL THEN 1 END) > 0
);

-- 12. 
SELECT DISTINCT g.*
FROM `group` g
JOIN student s ON s.group_id = g.id
LEFT JOIN marks m ON s.id = m.stud_id
JOIN subject sub ON m.subj_id = sub.id
WHERE sub.report_type = 'paper' AND m.grade IS NULL;

-- 13. 
SELECT DISTINCT sub1.name
FROM subject sub1
JOIN marks m1 ON sub1.id = m1.subj_id
WHERE m1.grade IS NULL
AND EXISTS (
    SELECT 1
    FROM marks m2
    WHERE m2.stud_id = m1.stud_id
    AND m2.subj_id <> sub1.id
    AND m2.grade IS NOT NULL
);

-- 14. 
SELECT s.surname, AVG(m.grade) AS avg_grade
FROM student s
JOIN `group` g ON s.group_id = g.id
JOIN marks m ON s.id = m.stud_id
WHERE g.shifr = 'ИТПМ-124' AND m.semester = 3 AND m.report_type = 'exam'
GROUP BY s.id, s.surname
ORDER BY avg_grade DESC;

-- 15. 
SELECT AVG(m.grade) AS avg_grade
FROM marks m
JOIN subject s ON m.subj_id = s.id
JOIN student st ON m.stud_id = st.id
WHERE s.name = 'Дифференциальные уравнения' AND st.name = 'Давид' AND m.report_type = 'exam';

-- 16. 
SELECT s.id, s.surname, s.name, AVG(m.grade) AS avg_grade
FROM student s
JOIN marks m ON s.id = m.stud_id
WHERE s.name LIKE '%Степан%'
GROUP BY s.id, s.surname, s.name;

-- 17. 
SELECT sub.name
FROM subject sub
WHERE EXISTS (
    SELECT 1
    FROM `group` g
    JOIN student s ON s.group_id = g.id
    JOIN marks m ON s.id = m.stud_id
    WHERE m.subj_id = sub.id
    GROUP BY g.id
    HAVING SUM(CASE WHEN m.grade IS NULL OR m.grade < 2 THEN 1 ELSE 0 END) >= (COUNT(s.id) / 2)
);

-- 18. 
SELECT sub.name
FROM subject sub
JOIN marks m ON sub.id = m.subj_id
WHERE sub.report_type = 'rating' AND m.grade IS NULL
GROUP BY sub.id, sub.name
HAVING COUNT(*) >= 5;

-- 19. 
SELECT s.id, s.surname, s.name, AVG(m.grade) AS avg_grade
FROM student s
JOIN marks m ON s.id = m.stud_id
WHERE m.semester BETWEEN 1 AND 8
GROUP BY s.id, s.surname, s.name
HAVING COUNT(DISTINCT m.semester) = 8 AND COUNT(CASE WHEN m.grade >= 2 THEN 1 END) = 8;

-- 20.
SELECT s.*
FROM student s
JOIN marks m3 ON s.id = m3.stud_id AND m3.semester = 3
LEFT JOIN marks m1 ON s.id = m1.stud_id AND m1.semester IN (1,2)
WHERE m3.grade >= 2
GROUP BY s.id, s.surname, s.name
HAVING COUNT(CASE WHEN m1.grade IS NULL OR m1.grade < 2 THEN 1 END) > 0;
