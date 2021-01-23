--=============================================
--kh계정
--=============================================
show user;

--table sample 생성
create table sample(
id number
);

--현재 계정의 소유 테이블 목록 조회
select*from tab;

--사원테이블
select*from employee;
--부서테이블
select*from department;
--직급테이블
select*from job;
--지역테이블
select*from location;
--국가테이블
select*from nation;
--급여등급테이블
select*from sal_grade;

--표 =table= entity= relation: 데이터를 보관하는 객체
--열=column =field=attribute 세로 : 데이터가 담길 형식
--행=row=record=tuple : 가로: 실제 데이터
--도메인=domain : 하나의 컬럼에서 취할 수 있는 값의 범위(그룹)

--테이블명세
--컬럼명      널 여부    자료형
describe employee;
desc employee;

--=====================================================
--DATA TYPE
--=====================================================
--컬럼에 지정해서 값을 제한적으로 허용.
--1.문자형 varchar2 | char
--2.숫자형 number
--3.날짜시간형 date | timestamp
--4.LOB (large object)

---------------------------------------------------------------------
--문자형
---------------------------------------------------------------------
--고정형 char(byte) : 최대 2000byte
--   char(10) 'korea' 영소문자는 글자당 1byte이므로 실제크기 5byte. 고정형 10byte로 저장됨.
--                  '안녕' 한글은 글자당 3byte(11g XE)이므로 실제크기 6byte 고정형 10byte 저장됨.                    
--가변형 varchar2(byte) : 최대 4000byte
--      varchar2(10) 'korea' 영소문자는 글자당 1byte이므로 실제크기 5byte, 가변형 5byte로 저장됨.
--                  '안녕' 한글은 글자당 3byte(11g XE)이므로 실제크기 6byte  가변형 6byte 저장됨.   
--고정형, 가변형 모두 지정한 크기 이상의 값은 추가할 수 없다.

--가변형 long : 최대 2GB
--LOB타입의 (Large object) 중의 CLOB(Character LOB)는 단일컬럼 최대 4GB까지 지원

create table tb_datatype(
 --컬럼명 자료형 널여부 기본값 
    a char(10),
    b varchar2(10)
);

--테이블 조회
select a,b -- *는 모든 컬럼
from tb_datatype; -- 테이블명

--데이터추가: 한행을 추가
insert into tb_datatype
values('hello', 'hello');

insert into tb_datatype
values('안녕', '안녕');

insert into tb_datatype
values('12345', '12345');

--insert into tb_datatype
--values('에브리바디', '안녕'); --ORA-12899: value too large for column "KH"."TB_DATATYPE"."A" (actual: 15, maximum: 10)

--데이터가 변경(insert, update,delete)되는 경우, 메모리상에서 먼저 처리된다.
--commit을 통해 실제 database에 적용해야 한다.
commit;

--lengthb(컬럼명): number- 저장된 데이터의 실제크기를 리턴
select a, lengthb(a), b, lengthb(b)
from tb_datatype;

---------------------------------------------------------------------
--숫자형
---------------------------------------------------------------------
--정수, 실수를 구분치 않는다.
--number(p,s)
--p : 표현가능한 전체 자리수
--s : p중 소수점 이하자리수 

/*
값 1234.567
--------------------------------------
number               1234.567
number(7)            1235      --반올림
number(7,1)         1234.6    --자동반올림처리
number(7,-2)        1200      --반올림


*/

create table tb_datatype_number(
    a number,
    b number(7),
    c number(7,1),
    d number(7,-2)
);

select*from tb_datatype_number;

insert into tb_datatype_number
values(1234.567, 1234.567, 1234.567, 1234.567);

--지정한 크기보다 큰 숫자는 ORA-01438: value larger than specified precision allowed for this column 유발 
insert into tb_datatype_number
values(1234567890.123, 1234567.567, 123456.5678, 1234.567);

commit;

rollback; --마지막 커밋시점 이후 변경사항은 취소된다.

---------------------------------------------------------------------
--날짜시간형
---------------------------------------------------------------------
--date 년월일시분초
--timestamp 년월일시분초 밀리초 지역대

create table tb_datatype_date(
    a date,
    d TIMESTAMP
);

--to_char 날짜/숫자를 문자열로 표현
select to_char(a, 'yyyy/mm/dd hh24:mi:ss'), d
from tb_datatype_date;

insert into tb_datatype_date
values(sysdate,systimestamp);


--날짜형+-숫자(1=하루) =날짜형
select to_char(a, 'yyyy/mm/dd hh24:mi:ss'),
          to_char(a-1, 'yyyy/mm/dd hh24:mi:ss'), 
            d
from tb_datatype_date;

--날짜형-날짜형 = 숫자(1=하루)
select sysdate - a --0.009일차
from tb_datatype_date;

--to_date 문자열을 날짜형으로 변환 함수
select_to_date('2021/01/23') - a
from tb_datatype_date;

--dual 가상테이블
select (sysdate+1) - sysdate
from dual;

--=====================================================
--DQL
--=====================================================
--Data Query Languageg 데이터 조회(검)을 위한 언어
--select문
--쿼리 조회 결과를 ResultSet(결과집합)라고 하며, 0행 이상을 포함한다.

--from절에 조회하고자 하는 테이블 명시
--where절에 의해 특정행을 filtering 가능.
--select절에 의해 컬럼을 filtering 또는 추가 가능
--order by 절에 의해 행을 정렬할 수 있다.

/*
구조

select 컬럼명 (5)                       필수
from 테이블명 (1)                     필수
where 조건절 (2)                       선택
group by 그룹 기준 컬럼 (3)        선택
having 그룹조건절 (4)                선택
order by 정렬기준컬럼 (6)          선택

*/
select *
from employee
where dept_code = 'D9' --데이터는 대소문자 구분
order by emp_name asc; --오름차순

--1. job테이블에서 job_name컬럼 정보만 출력
select job_name
from job;
--2. department테이블에서 모든 컬럼을 출력
select *
from department;
--3. employee테이블에서 이름, 이메일, 전화번호, 입사일을 출력
select emp_name, emp_no, email, phone
from employee;

--4. employee테이블에서 급여가 2,500,000원 이상인 사원의 이름과 급여를 출력
select emp_name, salary
from employee
where salary >= 2500000;
--5. employee테이블에서 급여가 3,500,000원 이상이면서 직급코드가 'J3'인 사원을 조회
--&& || t이 아닌 and or만 사용가능 
select *
from employee
where salary >= 3500000 and job_code = 'J3';
--6. employee테이블에서 현재 근무중인 사원을 이름 오름차순으로 정렬해서 출력
select *
from employee
where quit_yn = 'N'
order by emp_name;

--------------------------------------------------------------------
--select
---------------------------------------------------------------------
--table에 존재하는 컬럼
--가상컬럼 (산술연산)
--임의의 값 (literal)
--각 컬럼은 별칭(alias)을 가질 수 있다. as와 ""쌍따옴표는 생략가능.
--                 ㄴ별칭에 공백, 특수문자가 있거나 숫자로 시작하는 경우 쌍따옴표 필수

select emp_name as "사원명", --별칭은 쌍따옴표로 쓴다!
          phone "전화번호", --as 생략이 가능하다.
          salary 급여, --쌍따옴표도 생략이 가능 
          salary * 12 "연 봉",
          123 "123abc",
          '안녕'
from employee;

--실급여 : salary + (salary + bonus)
select emp_name,
         salary,
         bonus,
         salary + (salary * nvl(bonus, 0)) 실급여
from employee;

--null값과는 산술연산 할 수 없다. 그 결과는 무조건 null이다.
--null % 1(X) 나머지 연산자는 사용불가
select null + 1, 
         null - 1,
          null * 1,
          null / 1
from dual; -- 1행짜리 가상테이블 

--nvl(col,null일때 값) null처리 함수
--col의 값이 null 이 아니면, (col)값 리턴
--col의 값이 null이면 (null일때 값)을 리턴

select bonus,
          nvl(bonus, 0)  --null처리 후
from employee;

--distinct 중복제거용 키워드
--select절에 단 한번 사용가능하다.
--직급코드를 중복없이 출력

select distinct job_code
from employee;

--여러 컬럼 사용시 컬럼을 묶어서 고유한 값으로 취급한다. 
select distinct job_code, dept_code
from employee;

--뮨자 연결연산자 ||
-- +는 산술연산만 가능하다.

select '안녕' || '하세요'
from dual;

select emp_name || '(' || phone || ')'
from employee;

-----------------------------------------------------------------------------
-- where
-----------------------------------------------------------------------------
--테이블의 모든 행중에 결과집합에 포함될 행을 필터링한다.
--특정행에 대해 true(포함) | false(제외) 결과를 리턴한다.

/*
  +                             같은가
  !=  ^=  <>                다른가
  > < >= <=
  between .. and ..     범위연산
  like, not like            문자패턴연산
  is null , is not null     null여부
  in, not in                값목록에 포함여부
  
  and 
  or
  not                           제시한 조건 반전
  
*/

--부서코드가 D6인 사원 조회
select emp_name, dept_code
from employee
where dept_code = 'D6';

--부서코드가 D6가 아닌 사원 조회
select emp_name, dept_code
from employee
where not dept_code = 'D6';

select emp_name, dept_code
from employee
where dept_code ^= 'D6';

select emp_name, dept_code
from employee
where dept_code <> 'D6';

select emp_name, dept_code
from employee
where dept_code != 'D6';

--급여가 2,000,000원 보다 많은 사원 조회

select emp_name, salary
from employee
where salary>2000000;

--날짜형 크기비교 가능
--과거 < 미래
select emp_name,hire_date
from employee
where hire_date < '2000/01/01'; --날짜형식의 문자열은 자동으로 날짜형으로 형변환

--20년 이상 근무한 사원 조회 : 
--날짜형 - 날짜형 = 숫자(1=하루)
--날짜형-숫자(1=하루) = 날짜형

select emp_name, hire_date, quit_yn
from employee
where quit_yn = 'N' and  sysdate - hire_date >= 20*365;

--부서코드가 D6이거나 D9인 사원 조회

select emp_name, dept_code
from employee
where dept_code = 'D6' or dept_code = 'D9' ;

--범위연산
--급여가 200만원이상 400만원 이하인 사원 조회(사원명,급여)
select emp_name, salary
from employee
where salary between 2000000 and 4000000; --이상 이하 

--입사일이 1990/01/01~2001/01/01 인 사원조회(사원명, 입사일)
select emp_name, hire_date
from employee
where  quit_yn= 'N' 
    and hire_date between '1990/01/01' and '2001/01/01';
    
--like, not like
--문자열 패턴 비교 연산

--wildcard : 패턴 의미를 가지는 특수문자
--_ 아무문자 한글자 
--% 아무문자 0개 이상

select emp_name
from employee
where emp_name like '전%'; --전으로 시작, 0개이상의 문자가 존재하는가
--전,전차,전진,전형돈, 전전전전전(O)
--파전(X)

select emp_name
from employee
where emp_name like '전__%'; --전으로 시작, 연달아 두개의 문자가 존재하는가
--전형동, 전전전(O)
--전, 전진, 파전, 전당포아저씨 (X)

--이름에 가운데 글자가 '옹'인 사원 조회, 단 이름은 세글자이다.
select emp_name
from employee
where emp_name like '_옹_%';

--이름에 '이'가 들어가는 사원조회
select emp_name
from employee
where quit_yn = 'N' and  emp_name like '%이%';

--email컬럼값의 '_'이전 글자가 3글자인 이메일을 조회
select emp_name, email
from employee
--where email like '____%';--4글자 이후 0개이상의 문자열이 뒤따르는가를 검사한것...... ->문자열이 4글자 이상인가
where email like '___#_%' escape '#'; --임의의 escaping 문자 등록, 데이터에 존재하지 않을 것.

--in, not in 값목록에 포함여부 
--부서코드가 D6 또는 D8 인 사원을 조회

select emp_name, dept_code
from employee
where dept_code ='D6' or dept_code = 'D8';
--이렇게 바꿀수있다.
select emp_name, dept_code
from employee
where dept_code in ('D6', 'D8');--개수제한없이 값나열

--반대
select emp_name, dept_code
from employee
where dept_code not in ('D6', 'D8');
--이렇게 바꿀수있다.
select emp_name, dept_code
from employee
where dept_code !='D6' and dept_code!='D8'; 

--is null, is not null : null비교연산
--인턴사원 조회
--null값은 산술연산, 비교연산 모두 불가능하다.
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
--where dept_code = null; --안된다
WHERE DEPT_CODE IS NULL; --반대 is not null;

--D6, D8부서원이 아닌 사원조회(인턴사원포함)
select emp_name, dept_code
from employee
where dept_code not in ('D6','D8') or dept_code is null;

--nvl버전
select emp_name,nvl(dept_code,'인턴') --dept_code
from employee
where nvl(dept_code, 'D0') not in ('D6', 'D8');

-------------------------------------------------------------------------
--order by
-------------------------------------------------------------------------
--select 구문 중 가장 마지막에 처리
--지정한 컬럼 기준으로 결과집합을 정렬해서 보여준다.

--number   0 < 10
-- string    ㄱ < ㅎ, a < z
-- date      과거<미래
--null값 위치를 결정가능 : null first  |  nulls last
--asc 오름차순(기본값)
--desc 내림차순
--복수개의 컬럼 차례로 정렬 가능

select emp_id, emp_name, dept_code, job_code, hire_date
from employee
order by dept_code desc nulls last; -- 내림차순 desc

select emp_id, emp_name, dept_code, job_code, hire_date
from employee
order by dept_code, job_code;

--부서 급여 내림차순
select emp_id, emp_name, dept_code, job_code,salary, hire_date
from employee
order by salary desc;

--alias 사용가능
select emp_id 사번,
        emp_name 사원명
from employee
order by 사원명;

--1부터 시작하는 컬럼순서 사용가능 (비추)
select *
from employee
order by 9 desc;

--========================================================
--built-in function
--========================================================
--일련의 실행코드 작성해두고 호출해서 사용함.
--반드시 하나의 리턴값을 가짐.

--1.단일행 함수 : 각 행마다 반복호출되어서 호출된 수만큼 결과를 리턴함.
--      a. 문자처리함수
--      b. 숫자처리함수
--      c. 날짜처리함수
--      d. 형변환 함수
--      e. 기타함수
--2.그룹함수 : 여러행을 그룹핑한 후 그룹 당 하나의 결과를 리턴함.

---------------------------------------------------------------------
--단일행 함수
---------------------------------------------------------------------

--*************************************************************
--a.문자처리함수
--*************************************************************

--length(col): number
--문자열의 길이를 리턴
select emp_name, length(emp_name)
from employee;

--where절에서도 사용가능
select emp_name, email
from employee
where length(email) < 15;

--lengthb(col)
--값의 byte수 리턴
select emp_name,lengthb(emp_name),
        email,lengthb(email)
from employee;

--instr(string, search[,startposition[, occurence]])
--string에서 search가 위치한 index를 반환.
--oracle에서는 1-based index, 1부터 시작 
--startposition 검색시작위치
--occurence 출현순서
select instr('kh정보교육원 국가정보원', '정보'), --3 (왼쪽부터 3번지에 있다는것을 알려줌)
            instr('kh정보교육원 국가정보원', '안녕'),--0 값없음 
            instr('kh정보교육원 국가정보원', '정보', 5), --11 
            instr('kh정보교육원 국가정보원 정보문화사', '정보',1,3), --15(1번지부터 검색해서 3번째에 있는 정보의 번지를 찾아라)
            instr('kh정보교육원 국가정보원', '정보', -1) --11 마이너스는 뒤에서부터 찾는다.= 정보원
from dual;

--email컬럼값중 '@'의 위치는?(이메일, 인덱스)
select email, instr(email,'@')
from employee;


--substr(string, startindex[,length])
--string에서 startindex부터 length개수만큼 잘라내어 리턴
--length 생략시에는 문자열 끝까지 반환

select substr('show me the money',6, 2),--me
        substr('show me the money',6), -- me the money
        substr('show me the money',-5,3) --mon
from dual;


--@실습문제 : 사원명에서 성(1글자로 가정)만 중복없이 사전순으로 출력
select distinct substr(emp_name,1,1) 성
from employee
order by 성;

-- lpad|rpad(string,byte[, padding_char])
--byte수의 공간에 string을 대입하고, 남은공간은 padding_char를 (왼쪽|오른쪽)에 채울것.
--padding char는 생략시 공백문자.

select lpad(email,20,'#'),
        rpad(email,20,'#'),
       '['|| lpad(email,20)||']'
from employee;

--@실습문제: 남자사원만 사번, 사원명, 주민번호, 연봉조회
--주민번호 뒤 6자리는 ******숨김처리할 것.
select emp_id,
            emp_name,
            substr(emp_no, 1, 8)||'******'emp_no,-- rpad(substr(emp_no1, 8),14, '*') emp_no
            (salary + (salary * nvl(bonus,0)))* 12 annul_pay
from employee
where substr(emp_no, 8, 1) in ('1','3');

--@실습문제
    create table tbl_escape_watch(
        watchname   varchar2(40)
        ,description    varchar2(200)
    );
    --drop table tbl_escape_watch;
    insert into tbl_escape_watch values('금시계', '순금 99.99% 함유 고급시계');
    insert into tbl_escape_watch values('은시계', '고객 만족도 99.99점를 획득한 고급시계');
   
    commit;
   
    select * from tbl_escape_watch;
    

    
--tbl_escape_watch 테이블에서 description 컬럼에 99.99% 라는 글자가 들어있는 행만 추출하세요.
select *
from tbl_escape_watch
where description like '%99.99\%%' ESCAPE '\';

--@실습문제
--파일경로를 제외하고 파일명만 아래와 같이 출력하세요.
    
    create table tbl_files
    (fileno number(3)
    ,filepath varchar2(500)
    );
    insert into tbl_files values(1, 'c:\abc\deft\salesinfo.xls');
    insert into tbl_files values(2, 'c:\music.mp3');
    insert into tbl_files values(3, 'c:\documents\resume.hwp');
    
    commit;
    
    select * 
    from tbl_files;
    
--출력결과 :
----------------------------
--파일번호          파일명
-----------------------------
--1             salesinfo.xls
--2             music.mp3
--3             resume.hwp
-----------------------------

select fileno 파일번호, substr(filepath, instr(filepath,'\',-1,1)+1) 파일명
from tbl_files;

