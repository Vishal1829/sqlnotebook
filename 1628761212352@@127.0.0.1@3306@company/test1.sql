-- Active: 1628761212352@@127.0.0.1@3306@company

SELECT * FROM emp;
SELECT * FROM project;
SELECT * FROM dept;

SELECT e.*
FROM emp e JOIN dept d ON e.dno=d.dnumber
JOIN project p ON d.dnumber=p.dnum
WHERE p.pname='ProductX';

SELECT * FROM dept
WHERE dnumber = (
  SELECT dnum FROM project
  GROUP BY dnum
  ORDER BY COUNT(*) DESC
  LIMIT 1
);

SELECT *
FROM emp e JOIN dept d ON e.ssn=d.mgrssn
ORDER BY d.mgrstartdate
LIMIT 1;
