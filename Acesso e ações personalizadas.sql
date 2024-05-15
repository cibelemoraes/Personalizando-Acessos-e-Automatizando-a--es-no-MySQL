use ecommerce;

create user 'geral'@localhost identified by '123454321';
grant all privileges on testuser.* to 'geral'@localhost;
drop table employee;

drop trigger null_value_check;
create table if not exists employee(
Fname varchar(10),
Minit char(3),
Lname varchar(15),
Sex char(1),
Ssn varchar(13),
Address varchar(50),
Dno int,
Salary decimal(10,2)
); 

-- Número de empregados por departamento e localidade:
CREATE VIEW EmployeeCountByDeptLoc AS
SELECT Dno, COUNT(*) AS EmployeeCount
FROM employee
GROUP BY Dno;

--Lista de departamentos e seus gerentes:
CREATE VIEW DeptManagers AS
SELECT D.dname AS Department, E.Fname AS Manager_FirstName, E.Lname AS Manager_LastName
FROM employee AS E
JOIN department AS D ON E.Ssn = D.Mgr_ssn;

-- Projetos com maior número de empregados (ordenado por número de empregados, decrescente):
CREATE VIEW ProjectsMostEmployees AS
SELECT P.pname AS Project, COUNT(*) AS EmployeeCount
FROM employee AS E
JOIN works_on AS W ON E.Ssn = W.Essn
JOIN project AS P ON W.Pno = P.Pnumber
GROUP BY P.pname
ORDER BY COUNT(*) DESC;

-- Lista de projetos, departamentos e gerentes:
CREATE VIEW ProjectDeptManagers AS
SELECT P.pname AS Project, D.dname AS Department, E.Fname AS Manager_FirstName, E.Lname AS Manager_LastName
FROM project AS P
JOIN department AS D ON P.Dnum = D.Dnumber
JOIN employee AS E ON D.Mgr_ssn = E.Ssn;

-- seleciona os funcionários cujo salário seja maior que $27,000

drop view employees_salary_27000_view;
create view employees_salary_27000_view as
	select concat(Fname,Minit,Lname) as Name, Salary, Dno as Dept_number from employee
    where Salary > 26999;
    
-- vizualizando , salários e números de departamento de todos os funcionários do sexo masculino
drop view employees_salary_view;
create view employees_salary_view as
	select concat(Fname,Minit,Lname) as Name, Salary, Dno as Dept_number from employee
    where Sex = 'M';

-- vizualizando as view
select * from EmployeeCountByDeptLoc  
select * from DeptManagers  
select * from ProjectsMostEmployees
select * from ProjectDeptManagers   
select * from employees_salary_27000_view;
select * from employees_salary_view;


delimiter //



/*esta trigger é usada para garantir que todas as inserções na tabela employee tenham a coluna Address
 preenchida. Se Address estiver vazio, uma mensagem é inserida na tabela user_messages solicitando 
 ao novo funcionário que atualize seu endereço. Se Address não estiver vazio, uma mensagem de erro
  é registrada na tabela user_messages*/


-- Trigger antes da exclusão (before delete)
CREATE TRIGGER before_employee_delete
BEFORE DELETE ON employee
FOR EACH ROW
BEGIN
    INSERT INTO user_messages (message, ssn) VALUES ('Um registro de funcionário foi excluído.', OLD.Ssn);
END;

-- Trigger antes da atualização do salário (before update)
CREATE TRIGGER before_salary_update
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN
    DECLARE new_salary DECIMAL(10, 2);
    SET new_salary = NEW.Salary;
    
    -- Verifica se o novo salário é maior que o salário atual
    IF (new_salary > OLD.Salary) THEN
        -- Se o aumento de salário for registrado com sucesso
        INSERT INTO user_messages (message, ssn) VALUES ('Aumento de salário registrado com sucesso.', NEW.Ssn);
    ELSE
        -- Se não for, exibe uma mensagem de erro
        INSERT INTO user_messages (message, ssn) VALUES ('Erro: O novo salário não é maior que o salário atual.', NEW.Ssn);
    END IF;
END;
