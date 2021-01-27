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

select fileno 파일번호
--        ,instr(filepath,'\',-1) 인덱스
        ,substr(filepath,instr(filepath,'\',-1)+1) 파일명
    from tbl_files;


--*************************************************************
--b.숫자처리함수
--*************************************************************

--mod(피젯수, 젯수)
--나머지 함수, 나머지연산자 %가 없다. 

select mod(10,2), --0
        mod(10,3), --1
        mod(10,4) --2
from dual;

--입사년도가 짝수인 사원 조회
select emp_name,
          extract(year from hire_date)year -- 날짜함수 : 년도추출
from employee
where mod(year,2) = 0 -- ORA-00904: "YEAR" : Invalid identifier
where mod(extract(year from hire_date),2) = 0
order by year;

--ceil(number)
--소수점기준으로 올림
select ceil(123.456),
            ceil(123.456 *100)/100 -- 부동소수점 방식으로 처리
from dual;

--floor(number)
--소수점기준으로 버림
select floor(456.789),
            floor(456.789 * 10)/10
from dual;      

--riudn(number[,position])
--position기준(기본값 0, 소수점기준)으로 반올림 처리
select round(234.567), --235
            round(234.567,2), --234.57
            round(234.567,-1)--230
from dual;

--trunc(number[,position])
--버림
select trunc(123.567), --123
        trunc(123.567,2)--123.56
        from dual;

--*************************************************************
--c. 날짜처리함수
--*************************************************************
--날짜형 + 숫자 = 날짜형
--날짜형 - 날짜형 = 숫자

--add_months(date, number)
--date기준으로 몇달(number)전후의 날짜형을 리턴

select sysdate, -- 21/01/25
        add_months(sysdate,1), --21/02/25
        add_months(sysdate,-1),--20/12/25
        add_months(sysdate + 5, 1)--21/02/28

from dual;

--months_between(미래,과거)
--두 날짜형의 개월수 차이를 리턴한다.

select sysdate,
        to_date('2021/07/08'), -- 날짜형 변환 함수
        trunc(months_between(to_date('2021/07/08'), sysdate),1) diff
from dual;

--이름, 입사일, 근무개월수(n개월), 근무개월수(n년 n개월)조회
select emp_name "이름", hire_date "입사일",

       trunc(months_between(sysdate, hire_date)) ||'개월' "근무 개월수",
       trunc(months_between(sysdate, hire_date) / 12) || '년' ||
       mod(trunc(months_between(sysdate, hire_date)), 12) || '개월' "근무 개월수"
from employee;

--extract(year | month | day | hour | nimute | second from date) : number
--날짜형 데이터에서 특정필드만 숫자형으로 리턴
select extract (year from sysdate) yyyy, --2021
            extract(month from sysdate) mm, --1 (1부터 12월)
            extract(day from sysdate) dd, --25 
            extract(hour from cast(sysdate as timestamp)) hh,--16
            extract(minute from cast(sysdate as timestamp)) mm,--44
         extract(second from cast(sysdate as timestamp)) ss--21
from dual;

--2001년도 입사자만 조회하기

select emp_name, hire_date
from employee
where extract(year from hire_date) = 2001;


--trunc(date)
--시분초 정보를 제외한 년월일 정보만 리턴
select to_char(sysdate, 'yyyy/mm/dd hh24:mi:ss') date1, -- 2021/01/25 16:47:55
        to_char(trunc(sysdate), 'yyyy/mm/dd hh24:mi:ss') date2 --2021/01/25 00:00:00
from dual;

--*************************************************************
--d. 형변환함수
--*************************************************************
/*
--to_char
--to_date
--to_number

                 to_char            to_date
                 --------->        -------->
         number          string             date
                  <-------         <-------
                 to_number       to_char


*/

--to_char(date | number[, format])

select to_char(sysdate, 'yyyy/mm/dd (dy) hh24:mi:ss am') now, --2021/01/25 (월) 16:57:15 오후 
to_char(sysdate, 'yyyy/mm/dd (day) hh24:mi:ss am') now2, -- 2021/01/25 (월요일) 16:57:15 오후
to_char(sysdate, 'fmyyyy/mm/dd (dy) hh24:mi:ss am') now3,--형식문자로 인한 앞글자 0을 제거
to_char(sysdate, 'yyyy"년" mm "월" dd "일" ') now4-2021년 01월 25일
from dual;


select to_char(1234567, 'fmL9,999,999,999') won, --L은 지역화폐
             to_char(1234567, 'fmL9,999') won, --자릿수가 모자라서 ###########만 나오는 오류발생.
             to_char(123.4, 'fm999.99'),--123.40 소수점이상의 빈자리는 공란, 소수점이하 빈자리는 0처리
             to_char(123.4,'fm0000.00')--0123.40 빈자리를 모두 0으로 처리
from dual;

--이름, 급여(3자리 콤마), 입사일(1990-9-3(화))을 조회

select emp_name 이름, 
          to_char(salary, 'FML999,999,999')  급여, 
          to_char(hire_date,'yy/mm/dd(dy)') 입사일 
from employee;

--to_number(string, format)

--'\1,234,567' + 1234567 이런 연산 불가

select to_number('1,234,567', '9,999,999') + 100,
         to_number('￦3,000', 'L9,999') 
--        '1,234,567'+100 --안된다.
from dual;


--자동형변환 지원
select '1000' + 100, --1100
        '99' + '1', --100
        '99'||'1' --991
        from dual;
-- + 연산은 산술연산만 가능(JAVA의 문자열 더하기랑 개념이 다름)


--to_date(string, format)
--string이 작성된 형식문자 format으로 전달
select to_date('2020/09/09', 'yyyy/mm/dd')+ 1, -- 20/09/10
from dual;

--'2021/07/08 21:50:00' 를 2시간후의 날짜 정보를 yyyy/mm/dd hh24:mi:ss형식으로 출력
select to_char(to_date('2021/ 07/08 21:50:00', 
          'yyyy/mm/dd hh24:mi:ss') +  (2 / 24), 
          'yyyy/mm/dd hh24:mi:ss') result
from dual;

--현재시각 기준 1일 2시간 3분 4초 후의 날짜 정보를 yyyy/mm/dd hh24:mi:ss 형식으로 출력
--1시간: 1 / 24
--1분 : 1 / (24 * 60)
--1초 : 1 / (24 * 60  * 60)

select to_char(sysdate + 1 + (2 / 24) + (3 / (24 * 60)) + (4 / (24 * 60 * 60)), 
                      'yyyy-mm-dd hh24:mi:ss') result
from dual;

--기간타입
--interval year to month :년월 기간
--interval date to second : 일시분초 기간

--1년 2개월 3일 4시간 5분 6초후 조회
select to_char(add_months(sysdate,14)  + 3 + (4/24) + (5/24/60) + (6/24/60/60), 
            'yyyy/mm/dd hh24:mi:ss' )result
from dual;

select to_char(
         sysdate + to_yminterval('01-02')+ to_dsinterval('3 04:05:06'), --+는 기본값이라 생략
         'yyyy/mm/dd hh24:mi:ss'
         )result
from dual;

--numtodsinterval(diff, unit)
--numtoyminterval(diff, unit)
--diff : 날짜차이 
--unit :  year | month | day | hour | nimut | second
select extract(day from
            numtodsinterval(
            to_date('20210708', 'yyyymmdd') - sysdate,
            'day'
            )) diff --163
from dual;

--*************************************************************
--e. 기타함수
--*************************************************************
--null처리함수
--1. nvl(col, nullvalue)
select emp_name, bonus, nvl(bonus, 0)
from employee;

--2. nvl2(col, notnullvalue1, nullvalue2)
--col값이 null이 아니면 value1 리턴
--col이 null이면 value2 리턴
select emp_name,
        bonus,
        nvl(bonus,0)nvl1

select emp_name , 
          bonus,
          nvl2(bonus, '있음', '없음') "nvl2"
from employee;

--선택함수`
--decode(expr, 값1, 결과값1, 값2 , 결과값2, ......[, 기본값])
select emp_name,
          emp_no,
         decode(substr(emp_no, 8, 1), 1, '남', 2, '여', 3, '남', 4, '여') gender,--8번째 1글자 뽑아오고 1의 결과면 남, 2면 여, 3은 남, 4면 여 
       decode(substr(emp_no, 8, 1), 1, '남', 3, '남', '여') 성별--위와 같다. '여'가 기본값이 된다.
from employee;

--직급코드에 따라서 j1-대표, j2/j3- 임원, 나머지는 평사원으로 출력 (사원명, 직급코드, 직위)
select emp_name,
        job_code,
        decode(job_code, 'J1','대표','J2','임원','J3','임원', '평사원') 직위
from employee;

--where절에도 사용가능
--여사원만 조회
select emp_name,
            emp_no,
              decode(substr(emp_no, 8, 1), 1, '남', 3, '남', '여')  gender
from employee
where  decode(substr(emp_no, 8, 1), 1, '남', 3, '남', '여')  = '여';

--선택함수2
--case 
/*
type1(decode와 유사)

case 표현식
    when 값1 then 결과1
    when 값2 then rufrhk2
    .....
    [else 기본값]
    end
    
*/
select emp_no,
            case substr(emp_no,8,1)
                when '1' then '남'
                when '3' then '남'
                else '여'
                end gender
from employee       

/*
type2

2. 조건절 여러개
    case
        when 조건절1 then 결과1
        when 조건절2 then 결과2
        ...
        [else 기본값]
    end
*/

select emp_no,
            case substr(emp_no, 8, 1)
                when '1' then '남'
                when '3' then '남'
                else '여'
                end gender,
            case
                when substr(emp_no, 8, 1) in ('1', '3') then '남'
                else '여'
                end gender,
            job_code,
            case job_code
                when 'J1' then '대표'
                when 'J2' then '임원'
                when 'J3' then '임원'
                else '평사원'
                end job,
            case 
                when job_code = 'J1' then '대표'
                when job_code in ('J2', 'J3') then '임원'
                else '평사원'
                end job            
from employee;


----------------------------------------
-- GROUP FUNCTION
----------------------------------------
--여러행을 그룹핑하고, 그룹당 하나의 결과를 리턴하는 함수
--모든 행을 하나의 그룹, 또는 group by를 통해서 세부그룹지정이 가능하다.

--sum(col)
select  sum(salary), 
            sum(bonus), --null인 컬럼은 제외하고 누계처리
            sum(salary + (salary * nvl(bonus, 0))) --가공된 컬럼도 그룹함수 가능
from employee;

--select  emp_name, sum(salary) from employee;
--ORA-00937: not a single-group group function
--그룹함수의 결과와 일반컬럼을 동시에 조회할 수 없다.


--avg(col)
--평균
select round(avg(salary), 1) avg, 
            to_char(round(avg(salary), 1), 'FML9,999,999,999') avg
from employee;

--부서코드가 D5인 부서원의 평균급여 조회
select to_char(round(avg(salary), 1), 'FML9,999,999,999') avg
from employee
where dept_code = 'D5';

--남자사원의 평균급여 조회
select to_char(round(avg(salary), 1), 'FML9,999,999,999') avg
from employee
where substr(emp_no, 8, 1) in ('1', '3');


--count(col)
--null이 아닌 컬럼의 개수
-- * 모든 컬럼, 즉 하나의 행을 의미
select count(*), 
            count(bonus), --9 bonus컬럼이 null이 아닌 행의 수
            count(dept_code)
from employee;


--보너스를 받는 사원수 조회
select count(*)
from employee
where bonus is not null;

--가상컬럼의 합을 구해서 처리
select sum(
            case 
                when bonus is not null then 1
--                when bonus is null then 0
                end
            ) bonusman
from employee;

--사원이 속한 부서 총수(중복없음)
select count(distinct dept_code)
from employee;


--max(col) | min(col)
--숫자, 날짜(과거->미래),  문자(ㄱ->ㅎ)
select max(salary), min(salary),
            max(hire_date), min(hire_date),
            max(emp_name), min(emp_name)
from employee;

--@함수실습문제

--1. 직원명과 이메일, 이메일 길이를 출력하시오
 -- 이름        이메일       이메일길이
  --  ex)     홍길동 , hong@kh.or.kr         13
select emp_name 이름, email 이메일, length(email) 이메일길이
from employee;

--2. 직원의 이름과 이메일 주소중 아이디 부분만 출력하시오
-- ex) 노옹철   no_hc
--  ex) 정중하   jung_jh

select emp_name 이름, substr(email,1,instr(email,'@')-1) 아이디
from employee;

--3. 60년대에 태어난 직원명과 년생, 보너스 값을 출력하시오
-- 그때 보너스 값이 null인 경우에는 0 이라고 출력 되게 만드시오
--        직원명    년생      보너스
--    ex) 선동일   1962    0.3
--    ex) 송은희   1963    0
select emp_name 직원명, 19||substr(emp_no,1,2) 년생, nvl(bonus,0) 보너스
from employee
where substr(emp_no,1,1)='6';

--4. '010' 핸드폰 번호를 쓰지 않는 사람의 수를 출력하시오 
-- (뒤에 단위는 명을 붙이시오)
-- 인원  ex) 3명
select count(*)||'명' 인원수
from employee
where substr(phone,1,3)<>'010';

--5. 직원명과 입사년월을 출력하시오.
-- 단, 아래와 같이 출력되도록 만들어보시오
--  직원명          입사년월
-- ex) 전형돈       2012년12월
-- ex) 전지연       1997년 3월
select emp_name 직원명, 
    extract(year from hire_date)||'년 '||
    extract(month from hire_date)||'월' 입사년월
from employee;

--6.사원테이블에서 다음과 같이 조회하세요.
--[현재나이 = 현재년도 - 태어난년도 +1] 한국식 나이를 적용.
-------------------------------------------------------------------------
--사원번호    사원명       주민번호            성별      현재나이
-------------------------------------------------------------------------
--200        선동일      621235-1*******      남      57
--201        송종기      631156-1*******      남      56
--202        노옹철      861015-1*******      남      33
select emp_id 사원번호, emp_name 사원명,  emp_no 주민번호,
 case substr(emp_no, 8, 1)
            when '1' then '남'
            when '3' then '남'
            else '여'
       end 성별,
          case
            when substr(emp_no, 8, 1) in ('1', '2') then 1900 else 2000
       end + substr(emp_no, 1, 2) 출생년도,
       extract(year from sysdate) - (case when substr(emp_no, 8, 1) in ('1', '2') then 1900 else 2000 
       end + substr(emp_no, 1, 2)) + 1 현재나이
        
from employee;





--7. 직원명, 직급코드, 연봉(원) 조회
--단, 연봉은 \57,000,000으로 표시되게 함
-- 연봉은 보너스 포인트가 적용된 1년치 급여임
select emp_name 직원명, job_code 직급코드, to_char((salary +(salary * nvl(bonus,1)))*12, 'l9,999,999,999') "연봉(원)"
from employee;

--8. 부서코드가 D5, D9인 직원들 중에서 
--2004년도에 입사한 직원 중에 조회함.
--사번 사원명 부서코드 입사일
select emp_id 사번, emp_name 사번명, dept_code 부서코드, hire_date 입사일
from employee
where dept_code in ('D5','D9') and substr(hire_date,1,2)='04';

--9. 직원명, 입사일, 오늘까지의 근무일수 조회
--*주말도 포함, 소수점 아래는 버림
select emp_name 직원명, hire_date 입사일, trunc(sysdate-hire_date) 근무일수
from employee;

--10. 직원명, 부서코드, 생년월일, 나이(만) 조회
--단, 생년월일은 주민번호에서 추출해서,
--0000년 00월 00일로 출력되게 함.
--나이는 주민번호에서 추출해서 날짜데이터로 변환한 다음, 계산함
select emp_no from employee;
select extract(month from sysdate) from dual;
select emp_name 직원명, dept_code 부서코드,
    case
    when substr(emp_no,8,1) in ('1','2') then 1900
    else 2000
    end + substr(emp_no,1,2)||'년' || substr(emp_no,3,2)||'월' || substr(emp_no,5,2)||'일' "생년월일",
    extract(year from sysdate) - (case
    when substr(emp_no,8,1) in ('1','2') then 1900
    else 2000
    end + substr(emp_no,1,2))
     - (case
        when (extract(month from sysdate) - substr(emp_no,3,2)=0) and (extract(day from sysdate) - substr(emp_no,5,2)<0) then 1
        when (extract(month from sysdate) - substr(emp_no,3,2)<0) then 1
        else 0
    end) "만 나이"
from employee;

--11. 직원들의 입사일로부터 년도만 가지고, 
--각 년도별 입사인원수를 구하시오.
--아래의 년도에 입사한 인원수를 조회하시오.
--마지막으로 전체직원수도 구하시오.
--> decode, sum 사용

 -------------------------------------------------------------------------
 --    1998년   1999년   2000년   2001년   2002년   2003년   2004년  전체직원수
    -------------------------------------------------------------------------


select nvl(sum(decode(extract(year from hire_date), 1998, 1)), 0) "1998년",
        nvl(sum(decode(extract(year from hire_date), 1999, 1)), 0) "1999년",
        nvl(sum(decode(extract(year from hire_date), 2000, 1)), 0) "2000년",
        nvl(sum(decode(extract(year from hire_date), 2001, 1)), 0) "2001년",
        nvl(sum(decode(extract(year from hire_date), 2002, 1)), 0) "2002년",
        nvl(sum(decode(extract(year from hire_date), 2003, 1)), 0) "2003년",
        nvl(sum(decode(extract(year from hire_date), 2004, 1)), 0) "2004년",
        nvl(sum(decode(extract(year from hire_date), 1, 1, 1)), 0) "전체직원수"
from employee;

--12. 부서코드가 D5이면 총무부, D6이면 기획부, 
--D9이면 영업부로 처리하시오. (case 사용)
--단, 부서코드가 D5, D6, D9인 직원의 정보만 조회하고,
--부서코드 기준으로 오름차순 정렬함.
select emp_name 직원명, case
    when dept_code='D5' then '총무부'
    when dept_code='D6' then '기획부'
    when dept_code='D9' then '영업부'
    end 부서
from employee
where dept_code in ('D5','D6','D9')
order by dept_code;
                               
