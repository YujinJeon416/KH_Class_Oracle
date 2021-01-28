--======================================================
-- JOIN
--======================================================
--두개 이상의 테이블을 연결해서 하나의 가상테이블(relation)을 생성
--기준 컬럼을 가지고 행을 연결한다.

--송종기 사원의 부서는?

select dept_code
from employee 
where emp_name = '송종기';


select *
from department;

select dept_title
from department
where dept_id = 'D9';

--join

select D.dept_title
from employee E join department D --테이블 별칭 , as나 "" 안쓴다.
     on E.dept_code = D.dept_id
where E.emp_name = '송종기';

select * from employee;
select * from department;



-- 조인조건에 따른 구분
--1. Equi Join : 동등비교조건(=)에 의해 join (대부분의 join)
--2. Non-Equi Join : 동등비교가 아닌 join - between and, is null, is not null, in, not in, != 등 (가끔 사용)

-- 문법에 따른 구분
-- 1. ANSI 표준문법 : DBMS에 상관없이 사용할수 있는 표준 SQL문법( 모든 DBMS 공통문법)
-- 2. Vendor사 문법 : DBMS별로 지원하는 문법, ORACLE 전용 문법.  join키워드 없이 ,(콤마) 사용

--테이블 별칭
select emp_name,
        job_code,
        job_name
from employee join job
    on employee.job_code = job.job_code; -- ORA-00918: column ambiguously defined 
                                                            --employee 테이블에 있는 job_code인지 job_table에 있는 job_code인지 헷갈려서(두 테이블의 컬럼명이 같아서)
 
 
 select E.emp_name,
            J.job_code,
            J.job_name
from employee E join job J
on E.job_code = J.job_code;

--기준 컬럼명이 좌우테이블에서 동일하다면, on 대신 using 사용가능 
--usong을 사용한 경우는 해당컬럼에 별칭을 사용할 수 없다. 
--ORA-25154: column part of USING clause cannot have qualifier
select *
from employee E join job J
using(job_code);

select E.emp_name,
            job_code,--별칭을 사용할 수 없다.
            J.job_name
from employee E join job J
using(job_code);


-- 기준컬럼명이 다른 경우
select * from employee;
select * from department;

-- 컬럼명이 다르기 때문에 별칭이 없어도 구분할 수 있다.
-- 그러나 되도록 별칭을 명시해서, 가독성을 높일 것
select *
from employee E join department D
     on E.dept_code = D.dept_id
order by 1;
     --department에 가서 dept_code랑 dept_id가 같은 값으로 붙여라!
     
select dept_id, dept_title, location_id 
from employee join department
       on dept_code = dept_id
order by 1;


--equip-join 종류
/*
   1. inner join : 교집합, 내부조인

   2. outer join 외부조인 : 합집합 
                                    -left OUTER JOIN 좌측테이블 기준 합집합
                                    -right OUTER JOIN 우측테이블 기준 합집합
                                    -full OUTER JOIN 양테이블 기준 합집합

   3. cross join : 두테이블간의 조인할 수 있는 모든 경우의 수를 표현

   4. self join : 같은 테이블의 조인

   5. multiple join : 3개이상의 테이블을 조인 
*/


-- location nation 테이블을 조인해서 출력하세요.

select * from location;
select * from nation;

select L.local_code,
       L.national_code,
       L.local_name,
       N.national_name
from location L join nation N
     on L.national_code = N.national_code
order by 1;

--------------------------------------------------------
-- INNER JOIN
--------------------------------------------------------
-- A (inner) join B : inner 키워드는 생략이 가능.
-- 교집합. 
--1. 기준컬럼의 값이 null인 경우는 결과집합에서 제외됨.
--2. 기준컬럼의 값이 상대테이블에서 없는 경우, 결과 집합에서 제외 


--1.dept_code가 null인 행이 제외- 인턴 제외 : 기준컬럼의 값이 null인 경우
--detp_id  D3, D4, D7 제외 : 기준컬럼의 값이 상대테이블에서 없는 경우
select distinct D.dept_id
from employee E inner join department D
     on E.dept_code = D.dept_id -- 22행
order by 1;

select *
from department;

select *
from employee E join job J
     on E.job_code = J.job_code;

--(oracle)
-- ,(컴마)를 사용해서, 조인할 테이블 나열. 조인조건은 where절에 작성

select *
from employee E, department D
where E.dept_code = D.dept_id and E.dept_code = 'D5';

select *
from employee E, job J
     where E.job_code = J.job_code;
--------------------------------------------------------
-- OUTER JOIN
--------------------------------------------------------
--1. left (outer) join
-- 좌측테이블 기준
--좌측테이블의 모든 행이 포함. 우측테이블에는 on조건절에 만족하는 행만 포함 
--기준컬럼이 null이라면, 우측테이블의 모든 컬럼을 null처리

select *
from employee E left outer join department D
     on E.dept_code = D.dept_id;


--(oracle)
--기준컬럼(좌측) 반대편컬럼에 (+)기호를 붙여줌.

select *
from employee E, department D
where E.dept_code = D.dept_id(+);

--22 + 2 = 24행

--2. right outer join
--우측테이블 기준
--우측테이블 모든행이 포함, 좌측테이블에는 on조건절에 만족하는 행만 포함.

select *
from employee E right outer join department D
     on E.dept_code = D.dept_id;

--22 + 3 = 25행

--(oracle)
--기준컬럼(우측) 반대편에 (+)기호를 붙여줌.

select *
from employee E, department D
where E.dept_code(+) = D.dept_id;

--3. full outer join
--좌측테이블, 우측테이블 모든 행 사용
--완전조인

select *
from employee E full outer join department D
     on E.dept_code = D.dept_id;

-- 22 + 2(left) + 3(right) = 27

--(oracle) full은 지원하지 않는다.


--사원명/부서명 조회시
--부서지정이 안된사원은 제외 : inner join
--부서지정이 안된사원도 포함 : left join
--사원배정이 안된 부서도 포함 : right join


--------------------------------------------------------
-- CROSS JOIN
--------------------------------------------------------
--상호조인.
--on조건절 없이, 좌측테이블 행과 우측테이블의 행이 연결될 수 있는 모든 경우의 수를 포함한 결과집합.
--Cartesian's Product

select *
from employee E cross join department D; --216 = 24 * 9

 --(oracle) where 조건절을 명시하지 않으면 자동으로 cross join
select *
from employee E, department D;   

--일반컬럼, 그룹함수 결과를 함께 보고자 할 때. 

select trunc( avg(salary))
from employee;

select emp_name, salary, avg, salary - avg diff
from employee E cross join(select trunc( avg(salary)) avg
                                            from employee) A  -- (select trunc( avg(salary)) avg from employee) A ***확장성이 좋음***
                     
                     
                    
--------------------------------------------------------
-- SELF JOIN
--------------------------------------------------------
-- 조인시 같은 테이블을 좌/우측 테이블로 사용.
-- ex)사원별 관리자의 이름을 조회

--사번, 사원명, 관리자사번, 관리자명 조회
select E1.emp_id,
        E1.emp_name,
        E1.manager_id,
        E2.emp_id,
        E2.emp_name
from employee E1 join employee E2
        on E1.manager_id  =E2.emp_id;
        
--(oracle)
select E1.emp_id,
       E1.emp_name,
       E1.manager_id,
       E2.emp_name,
       E2.emp_id
from employee E1, employee E2
where E1.manager_in = E2.emp_id;

--------------------------------------------------------
-- MULTIPLE JOIN
--------------------------------------------------------
--한번에 좌우 두 테이블씩 조인하여 3대이상의 테이블을 연결함.
--3개 이상의 테이블 순서대로 조인
--ANSI문법에서는 테이블 작성 순서 중요!

--사원명, 부서명, 지역명,직급명
--employee - department - location - nation

select * from employee; -- E.dept_code
select * from department; --D.dept_id, D.location_id
select * from location; --L. local_code


--기준컬럼이 null이거나
--상대테이블에서 동일한 값을 갖는 기준컬럼이 존재하지 않는 경우

select E.emp_name,
       D.dept_title,
       L.local_name,
       J.job_name
from employee E
join job J
on E.job_code = J.job_code
    join department D
        on E.dept_code = D.dept_id
    join location L
        on D.location_id = L.local_code; 
--join job J
--on E.job_code = J.job_code; 여기서 해도 됨
--   where E.emp_name = '송종기';
   
--조인하는 순서를 잘 고려할 것
-- left join으로 시작했으면 끝까지 유지해줘야 데이터가 누락되지 않는 경우가 있다.   


--(oracle)

select *
from employee E, department D, location L, job J
where E.dept_code = D.dept_id(+)
      and D.location_id = L.local_code(+)
      and E.job_code =J.job_code;
      
-- 직급이 대리, 과장이면서, ASIA지역에 근무하는 사원조회
-- 사번, 이름, 직급명, 부서명, 급여, 근무지역, 국가

select * from employee;
select * from department;
select * from location;
select * from nation;
select * from job;

select E.emp_id 사번, E.emp_name 이름, J.job_name 직급명, D.dept_title 부서명, E.salary 급여, L.local_name 근무지역, N.national_name 국가
from employee E 
        left join job J 
        on E.job_code = J.job_code
        left join department D 
        on E.dept_code = D.dept_id
        left join location L 
        on D.location_id = L.local_code
        left join nation N 
        on L.national_code= N.national_code
where L.local_name like '%ASIA%' and J.job_name in ('대리', '과장');-- like '대리' or J.job_name like '과장';


--(olacle)
select E.emp_id 사번,
            E.emp_name 이름,
            J.job_name 직급명,
            d.dept_title 부서명,
            E.salary 급여,
            l.local_name 근무지역,
            l.national_code 국가
from employee E, department D, location L, job J
where E.job_code = J.job_code and E.dept_code = D.dept_id and D.location_id = L.local_code and 
            J.job_name in ('대리','과장') and L.local_name like 'ASIA%';

--non-equi join
--동등비교조건(=)외의 조건으로 조인하는 경우

select *
from sal_grade;

--급여등급 조회 employee.salary between sal_grade.min_sal and sal_grade.max_sal

select emp_name, salary, SG.sal_level
from employee E
     join sal_grade SG
          on E.salary between SG.min_sal and SG.max_sal
order by 3 desc,2;
     
