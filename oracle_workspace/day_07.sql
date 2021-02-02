
--------------------------------------------------------
-- 상관 sub-query
--------------------------------------------------------
-- 상호연관 서브쿼리
-- main-query의 값을 sub-query에 전달하고, 서브쿼리 수행 후 그 결과를 다시 main-query에 리턴해서 처리하는 방식
-- 각행마다 비교값이 다른 경우(각행의 컬럼값이 sub-query에 필요한 경우) 유용하다.
-- main-query의 table별칭이 반드시 필요하다.

-- 일반 sub-query : 단독으로 사용
-- 상관 sub-query : main-query로부터 값을 전달받아 사용

-- 직급별 평균급여보다 많은 급여를 받는 사원 조회
--join으로 처리
select *
from employee E
    join(
            select job_code, avg(salary) avg
            from employee
            group by job_code
        ) EA
        using(job_code)
where E.salary > EA.avg
order by job_code; 

--상관서브쿼리로 처리
select emp_name, job_code, salary
from employee E--메인쿼리 테이블 별칭이 반드시 필요
where salary > (select avg(salary)
                from employee
                where job_code = E.job_code)
order by 2;

select job_code, trunc(avg(salary))
from employee
group by job_code;

-- 부서코드별 평균급여보다 적은 급여를 받는 사원 조회(인턴포함)
select emp_name 사원명, nvl(dept_code, '인턴') 부서코드, salary 급여
from employee E
where salary < (select avg(salary)
                from employee
                where nvl(dept_code, '인턴') = nvl(E.dept_code, '인턴'))
order by 2;

--exists
--exists(sub-query) sub_quary에 행이 존재하면 참, 행이 존재하지 않으면 거짓
--sub-query의 결과집합에 행이 존재하면 true를 리턴, 0행을 리턴(subquery)하면 false를 리턴(main-query)

select *
from employee
where 1 = 1; -- 무조건 true

select *
from employee
where 1 = 0; -- 무조건 false

--행이 존재하는 서브쿼리 : exists true 참
select *
from employee
where exists (select * 
                        from employee
                        where 1 = 1);
--행이 존재하지 않는 서브쿼리 : exists false 거짓
select *
from employee
where exists (select * 
                        from employee 
                        where 1 = 0);
                        
                        

--관리하는 직원이 한명이라도 존재하는 관리자사원 조회
-- 누군가의 manager_id 컬럼에 본인의 emp_id 컬럼이 사용된다면 관리자
--누군가의 manager_id 컬럼에 본인의 emp_id 컬럼이 사용되지 않는다면 관리자가 아님
-- emp_id를 보고 employee table에서 manager_id로 사용하고 있다면 true, 결과집합 해당행 리턴

select emp_id, emp_name
from employee E
where exists (
                        select 1 
                        from employee 
                        where manager_id = E.emp_id
                        );
              
select *
from employee E;

select *
from employee 
where manager_id = '201';        

--부서테이블에서 실제사원이 존재하는 부서만 조회(부서코드, 부서명)
select dept_id 부서코드, dept_title 부서명
from department D
where exists (
                        select * 
                        from employee 
                        where dept_code = D.dept_id)
order by 1;

select * from department D;

select 1
from employee
where dept_code = 'D2';

--부서테이블에서 실제사원이 존재하지않는 부서만 조회(부서코드, 부서명)- not exists 
--not exists(sub-query) : sub-query의 결과행이 존재하지 않으면 true, 
                                     --sub-query의 결과행이 존재하면 false
select dept_id 부서코드, dept_title 부서명
from department D
where not exists (
                        select * 
                        from employee 
                        where dept_code = D.dept_id)
order by 1;

--최대/최소값 구하기(not exists)
--가장 많은 급여를 받는 사원을 조회
--가장 많은 급여를 받는다 - > 본인보다 많은 급여를 받는 사원이 존재하지 않는다.

select emp_name, salary
from employee E
where not exists(
                        select *
                        from employee
                        where salary > E.salary );
  
--가장 적은 급여를 받는 사원조회->본인보다 적은 급여를 받는 사원이 존재하지 않는다.                      
select emp_name, salary
from employee E
where not exists(
                        select *
                        from employee
                        where salary < E.salary );

--------------------------------------------------------
-- scala sub-query
--------------------------------------------------------
-- select절에 사용된 결과값 하나(1행 1열)인 상관 서브쿼리(서브쿼리의 실행결과가 1(단일행, 단일컬럼)인 상관서브쿼리)

--관리자 이름 조회

select emp_name, (select emp_name
                                from employee
                               where emp_id = E.manager_id) manager_name
from employee E;

--사원명, 부서명, 직급명 조회
select emp_name,
         nvl( (
                select dept_title
                from department
                where E.dept_code = dept_id
            ) , '인턴')dept_title,
            (
                select job_name
                from job
                where E.job_code= job_code
            ) job_name
from employee E;



-- 사번, 사원명, 관리자사번, 관리자명을 조회

select emp_id 사번,
       emp_name 사원명,
       manager_id 관리자사번,
       (select emp_name from employee where emp_id = E.manager_id) 관리자명
from employee E;

--@실습문제 : 사원, 부서코드, 급여, 부서별 평균급여를 조회
-- join 없이 부서별 평균급여는 scala sub-query 사용할 것

select emp_name 사원명,
       nvl(dept_code, '인턴') 부서코드,
       salary 급여,
       (select trunc(avg(salary)) 
        from employee 
        where nvl(dept_code, '인턴') = nvl(E.dept_code, '인턴')) "부서별 평균급여"
from employee E
order by 2;

-- 사원별로 전체평균급여와 차이를 조회
-- 전체 평균 급여를 함께 조회

select emp_name,
       salary,
       (select trunc(avg(salary)) from employee) "평균",
       salary - (select trunc(avg(salary)) from employee) "차이"
from employee;

-- 일반 sub-query는 블럭잡아서 실행하면 실행이 된다.

--------------------------------------------------------
-- inline-view
--------------------------------------------------------
-- from절에 사용한 sub-query를 inline-view라고 함.

-- view란?
-- 실제테이블에 근거해서 만들어진 가상테이블. 복잡한 쿼리를 계층적으로 단순화 시킬 수 있다.
-- 1. inline-view : 1회성으로 사용
-- 2. stored-view : 데이터베이스객체로 저장해서 재사용 가능.

-- 여자 사원 조회
select E.*, 
       decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') 성별
from employee E
where decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') = '여';

select emp_id, emp_name, gender
from (select emp_id, emp_name,
      decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') gender
      from employee E)
where gender = '여';

-- 30, 50대 여자사원 조회(사번, 이름, 부서명, 나이, 성별)
--inline-view 나이, 성별
select  *
from (select emp_id 사번, emp_name 이름,  
                        nvl((
                            select dept_title
                             from department
                           where E.dept_code = dept_id
                          ), '인턴') 부서명, 
                          extract(year from sysdate) - (decode(substr(E.emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(E.emp_no, 1, 2)) 
      + 1  age,
      decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') gender 
from employee E   )
where gender = '여' and age between 30 and 50;





-- 30, 40대 여자사원 조회(사번, 사원명, 성별, 나이)
select emp_id 사번, emp_name 사원명, gender 성별, age 나이
from (select E.*,
      decode(substr(emp_no, 8, 1), '1', '남', '3', '남', '여') gender,
      extract(year from sysdate) 
      - (decode(substr(E.emp_no, 8, 1), '1', 1900, '2', 1900, 2000) + substr(E.emp_no, 1, 2)) 
      + 1 age
      from employee E)
where gender = '여' and age between 30 and 49;

--======================================================
-- 고급 쿼리
--======================================================

--------------------------------------------------------
-- TOP-N 분석
--------------------------------------------------------
-- 상위 n개, 하위n개의 행을 조회
--급여를 많이 받는 top-5, 입사일이 가장 최근인 top-10조회 등 

-- rownum | rowid
-- 테이블 구조에 제공되는 가상컬럼
-- rowid : 특정 레코드(행)에 접근하기 위한 논리적 주소값. 데이터 추가 시 자동으로 부여
-- rownum : 각 행에 대한 일련번호. 데이터추가시 1부터 1씩 증가하며 자동으로 부여.
--          테이블행에 부여된 rownum은 변경불가.
--          where절, inline-view를 통해 테이블형태가 바뀌는 경우는 새로 부여됨.

select rownum, rowid, E.*
from employee E
order by salary desc;

--where절 사용시 rownum새로부여
select rownum, E.*
from employee E
where dept_code = 'D5';

--inline-view사용시
select rownum, E.*
from(
select rownum old, emp_name, salary
from employee
order by salary desc) E
where rownum between 1 and 5;

-- 급여 상위 TOP-5 조회

select rownum,
       e.*
from (
        select rownum AS old, E.*
        from employee E
        order by salary desc
      ) E
where rownum < 6;

--입사일이 빠른 10명 조회
select *
from (
        select emp_name, hire_date
        from employee E
        order by hire_date asc -- <--> desc 하면 입사일이 느린순서 
      ) E
where rownum <=10;

--입사일이 빠른 순서로 6번째에서 10번째 사원 조회
--rownum은 where절이 시작하면서 부여되고 where절이 끝나면 모든행에 대해 부여가 끝난다.
--offset(건너뜀)이 있다면 정상적으로 가져올 수 없다.
--inline-view를 한계층 더 사용해야한다.
select E.*
from(
                select rownum rnum, E.*
                from (
                        select emp_name, hire_date
                        from employee E
                        order by hire_date asc -- <--> desc 하면 입사일이 느린순서 
                      ) E
                ) E      
where rnum between 6 and 10;

-- 직급이 대리인 사원 중에서 급여 상위 3명을 조회

select rownum,
       emp_name,
       salary
from (
        select rownum old, emp_name, salary
        from employee E
        where job_code in (select job_code from job where job_name = '대리')
        order by salary desc
      ) E
where rownum < 4;

--강사님 답

select emp_name, job_name, salary
from (select *
      from employee E
           join job J
           using(job_code)
      where job_name = '대리'
      order by salary desc
      ) E 
where rownum <= 3;

-- 직급이 대리인 사원 중에서 연봉 top-3명을 조회 (순위,이름, 연봉)

select rownum,
       emp_name,
        salary * 12
from (
        select rownum old, emp_name, salary
        from employee E
        where job_code in (select job_code from job where job_name = '대리')
        order by  salary * 12  desc
      ) E
where rownum < 4;

--선생님 답

select rownum, E.*
from (
select emp_name,
(salary + (salary * nvl(bonus,0))) * 12 annual_salary
from employee
where job_code = (
                    select job_code
                    from job
                    where job_name =  '대리'
                    )
                    order by annual_salary desc
                    ) E
                    where rownum between 1 and 3;

-- 직급이 대리인 사원 중에서 연봉 4~6위(순위,이름, 연봉)

select E.*
from ( select rownum rnum, E.*     
from (
        select  emp_name, salary * 12
        from employee E
        where job_code in (select job_code from job where job_name = '대리')
        order by  salary * 12  desc
      ) E
      ) E
where rnum between 4 and 6; 

--강사님 답
select E.*
from (
select rownum rnum, 
E.*
from(
select emp_name,
(salary + (salary * nvl(bonus,0))) * 12 annual_salary
from employee
where job_code = (
                    select job_code
                    from job
                    where job_name =  '대리'
                    )
                    order by annual_salary desc
                    ) E
                    ) E
                    where rnum between 4 and 6;



-- 부서별 평균 급여 TOP-3 조회(순위, 부서명, 평균급여)

select * from department;

select rownum,
       E.dept_code,
       E.평균
from(
     select dept_code,trunc(avg(salary)) 평균
     from employee
     group by dept_code
     order by 2 desc
     ) E
where rownum < 4;

-- 강사님 답

select rownum , E.*
      
from (
      select dept_code, trunc(avg(salary)) avg
      from employee
      group by dept_code
      order by avg desc
     ) E
where rownum between 1 and 3;

--부서별 급여 상위 6~10위 조회

select E.*
from (
        select rownum rnum, E.*
        from (
                select --nvl(dept_code, '인턴') dept_code,
                            nvl((
                                    select dept_title 
                                    from department D 
                                    where dept_id = E.dept_code
                                  ), '인턴') dept_title, 
                            trunc(avg(salary)) avg
                from employee E
                group by dept_code
                order by avg desc
                ) E
         ) E
where rnum between 4 and 6;


/*
select E.*
from(
            select rownum rnum, E.*
            from(
                        <<정렬된 ResultSet>>
                    )E
            )E
where rnum btween 시작 and 끝;
*/

--with구문
--inline-view 서브쿼리에 별칭을 지정해서 재사용하게 함
with emp_hire_date_asc
as
 ( 
 select emp_name, hire_date
 from employee 
 order by hire_date asc 
 )
select E.*
from(
                select rownum rnum, E.*
                from emp_hire_date_asc E
                ) E      
where rnum between 6 and 10;


--1을 건너뛰고 쓰면 안나온다.
--*rownum의 완벽한 결과는 where절이 끝난 이후에 얻을 수 있다.
--1부터 순차적으로 처리하지 않는다면, inline-view 레벨을 하나 더 사용해야 한다.

select *
from (
    select emp_name, salary
    from employee
    order by salary desc
    )
where rownum between 6 and 10;

--올바른 방법

select *
from (
    select rownum rnum, E.*
    from (
        select emp_name, salary
        from employee
        order by salary desc -- level 1 : 랭킹 1위부터 10위까지는 여기서 이미 정렬됨
        ) E 
    ) E -- level2 : 여기서 새로 rownum 부여하는 작업
where rnum between 6 and 10; -- level3 : where절의 조건 적용

--부서별 평균급여랭킹에서 4~6위 조회 (부서명, 평균급여)
select * from department;

select *
from (
    select rownum rnum, E.*
    from (
        select nvl((select dept_title 
                    from department where dept_id = E.dept_code), '인턴') 부서명, 
                         trunc(avg(salary)) as 평균급여
        from employee E
        group by dept_code
        order by 평균급여 desc
        ) E
    ) E 
where rnum between 4 and 6; 

--------------------------------------------------------
-- WINDOW FUNCTION
--------------------------------------------------------
--행과 행간의 관계를 쉽게 정의하기 위한 표준함수

-- 1.순위함수
-- 2.집계함수
-- 3.분석함수
-- window function(args) over([partition by절][order by절][window절])
-- 1. args 윈도우함수 : 0 ~ n개의 인자를 전달
-- 2. partition by절 : grouping기준 컬럼 설정(window함수 안에서 group by 처리를 해준다)
-- 3. order by : 정렬기준컬럼 설정
-- 4. windowing : 처리할 행의 범위를 지정(특정한 행만 대상으로 한다거나)

--순위함수
--rank() over() : 순위를 지정
--급여 순위

select emp_name,
salary,
rank()over(order by salary desc) rank
from employee;

--dense_rank() over() : 빠진 숫자 없이 순위를 지정

select emp_name,
            salary,
            rank() over(order by salary desc) rank,
            dense_rank() over(order by salary desc) rank
from employee;


--그룹핑에 따른 순위 지정             

 select emp_name,
            dept_code,
               salary,
               rank() over(partition by dept_code order by salary desc) rank_by_dept
 from employee;
 
--부서별 급여 3위까지만 조회 -partition by 사용
 select E.*
 from(
     select emp_name,
            dept_code,
               salary,
               rank() over(partition by dept_code order by salary desc) rank_by_dept
 from employee
 )E
 where rank_by_dept between 1 and 3;

--6에서 10
select *
from (
        select emp_name,
               salary,
               rank() over(order by salary asc) rank,
               dense_rank() over(order by salary desc) dense_rank -- 빽빽한 랭크
               -- 그냥 rank로 하면 공동랭크가 있고 건너뛰는데 dense_rank는 다음 순위를 다시 매긴다
        from employee
     ) E
where rank between 6 and 10;

--입사일이 빠른 10명의 사원 조회

select *
from (
        select emp_name,
               hire_date,
               rank() over(order by hire_date) rank,
               dense_rank() over(order by hire_date) dense_rank -- 빽빽한 랭크
               -- 그냥 rank로 하면 공동랭크가 있고 건너뛰는데 dense_rank는 다음 순위를 다시 매긴다
        from employee
     ) E
where rank between 1 and 10;

--부서별로 급여랭킹 3위까지 조회

select *
from (
        select nvl(dept_code, '인턴'),
               emp_name,
               salary,
               rank() over(partition by dept_code order by salary desc) rank
        from employee
      ) E
where rank <= 3;

--직급별로 급여 상위 3명 조회

select *
from (
        select job_code,
               emp_name,
               salary,
               rank() over(partition by job_code order by salary desc) rank
        from employee E
        order by 1
      ) E
where rank <= 3;

--집계함수
--sum() over()
--일반컬럼과 같이 사용할 수 있다.
--사원명, 급여, 전체급여합계

--그룹함수는 일반함수하고 같이 쓸 수 없다.
select emp_name,
            salary,
            dept_code,
--         (select sum(salary) from employee) sum,
sum(salary) over() "전체사원급여합계", -- 윈도우함수는 일반 컬럼하고 함께 사용할 수 있다.
sum(salary) over(partition by dept_code) "부서별 급여합계",
sum(salary) over(partition by dept_code order by salary) "부서별 급여누계_급여"
from employee;


--avg() over()
select emp_name,
       dept_code,
       trunc(avg(salary) over(partition by dept_code)) "부서별평균급여"
from employee;

--count()over()
select emp_name,
        dept_code,
        count(*)over(partition by dept_code) cnt_by_dept
from employee;
