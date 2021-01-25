仍有疑问Q9,Q14
# 笔记1.innerjoin两侧两张表的别名可以在条件on中使用
# 笔记2.in 和not in 的使用
# 笔记3.groupby使用时，select的左侧必须以分组字段为第一项，聚合函数sum,max,avg,count为其他项
# 笔记4. 字段 like '李%'
# 笔记6. 多表相连时可能出现重复字段，报错信息为duplicate xxx，这时只需要将select导出内容不要输出其中一张表的该字段即可
# 笔记7. 用count记录学习过的内容总数，=total或<total可得结果
# 第九题太几把难了搞了半个小时都很混。。回头看
# 笔记10 in 与not in的使用。没学过首先先将学过的筛选出来 用一次in，后再使用notin
# 12 orderby进行升降序 desc，注意left join的使用，不正确的leftjoin 会出现大量的null
# 14 处理求几个个数时可以在select内使用sum配合case when xx then 1 else 0 但是这里的case后面为什么添加字段 score后会查不出来
# 1.1 查找同时存在01课程和02课程的情况
SELECT * FROM
SC a
INNER JOIN
SC b
on a.CId='01' AND b.CId='02' AND a.SId = b.SId


#1.2查询存在01课程但可能不存在02课程的情况，left join可以查出null的情况
SELECT *
FROM 
(SELECT * FROM
SC 
WHERE CId='01') a
LEFT JOIN
SC b
ON b.CId='02'
AND a.SId=b.SId


#1.3不存在01课程但存在02课程的情况

SELECT * FROM SC a
WHERE SId
not IN(SELECT SId FROM SC
WHERE CId='01')
AND a.CId='02'


# 2.查询平均成绩大于等于60的同学学生编号。
# 使用groupby时select中第一项必须为groupby分组的元素，第二项一般为所需的因子，需要用聚合函数实现，avg,sum,max
SELECT SId,AVG(score) FROM SC
GROUP BY SId
HAVING avg(score)>60


# 2.1 查询平均成绩大于等于60的同学学生编号。
SELECT *
FROM
(SELECT SId,AVG(score) FROM SC
GROUP BY SId
HAVING avg(score)>60) a
INNER JOIN
Student b
ON a.SId=b.SId


#3 查询在 sc 表中存在成绩的学生信息
SELECT * FROM
(SELECT SId FROM SC
GROUP BY SId) a
INNER JOIN
Student b
ON
a.SId = b.SId



# 4.查询所有同学的学生编号，姓名，选课总数，所有课程总成绩，没课程的显示null
SELECT *
FROM Student s
left JOIN
(SELECT SId,count(CId),SUM(score)
FROM SC
GROUP BY SId) a
on s.SId= a.SId



# 5.查询李老师的数量
SELECT COUNT(TId) FROM Teacher
WHERE Tname
LIKE '李%'


# 6.学过张三老师的课程，的学生信息
# 1.张三老师的tid，张三老师的课程有哪些，学生有哪些人修了这些课程
# 法1
SELECT *
FROM
(SELECT * FROM SC
WHERE CId = (
SELECT CId
FROM Course
WHERE TId=
(SELECT TId FROM
Teacher 
WHERE Tname='张三'))) a
INNER JOIN Student b
ON a.SId=b.SId

# 法2
SELECT * FROM Student a
INNER JOIN 
(
SELECT a.*,b.Cname,TId,Tname FROM SC a
INNER JOIN
(
SELECT a.*,b.Tname FROM Course a INNER JOIN Teacher b on a.TId=b.TId
) b
ON a.CId=b.CId
) b
ON a.SId=b.SId
AND b.Tname='张三'

# 7查询没有学全所有课程的同学信息

SELECT * 
FROM
(SELECT a.SId,COUNT(b.CId) AS countid
FROM Student a
LEFT JOIN
SC b
ON a.SId=b.SId
GROUP BY a.SId
HAVING countid=3
) a
INNER JOIN
Student b
ON a.SId=b.SId


#8.查询学过01同学学过的课程的同学

SELECT a.SId , COUNT(a.CId) AS countcl
FROM
SC a
INNER JOIN
(
SELECT CId
FROM
SC WHERE SId='01'
) b
ON a.CId=b.CId

GROUP BY SId
HAVING countcl>1


#9. 查找该同学学生信息
SELECT a.SId FROM 
(
SELECT * FROM SC WHERE SId NOT IN
(
SELECT SId FROM SC WHERE CId NOT IN
(
SELECT CId FROM SC WHERE SId='06'
)
)
) a
LEFT JOIN
Student b
ON a.SId=b.SId
GROUP BY a.SId HAVING COUNT(cid)=(SELECT COUNT(cid) FROM SC WHERE SId='06')


#10 查询没学过张三老师讲授的任意门课程的学生姓名
SELECT *
FROM
Student s
WHERE s.SId NOT IN
(
	SELECT SId FROM
	SC c
	WHERE CId
	IN
	(
		SELECT CId
		FROM 
		Course a
		INNER JOIN
		Teacher b
		ON a.TId=b.TId
		AND b.Tname='张三'
	)
)



#11.查询两门及其以上不及格课程的同学的学号，姓名，平均成绩

SELECT aa.*,ss.Sname FROM
(
SELECT
	SId
FROM
SC
WHERE score<60
GROUP BY
SId 
HAVING COUNT(SId)>1

) aa
LEFT JOIN
Student ss
ON aa.SId=ss.SId


#12.检索'01'课程分数小于60，按分数降序排列的学生信息
SELECT *
FROM
Student s
INNER JOIN
(
	SELECT *
	FROM
	SC
	WHERE score<60 AND CId='01'
	ORDER BY 
	score DESC
) b
ON s.SId=b.SId


#13 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩


SELECT * FROM SC a
LEFT JOIN
(
SELECT SId, AVG(score) AS avscore
FROM SC
GROUP BY SId
) b
ON a.SId=b.SId
ORDER BY avscore DESC


#14.查及格率
SELECT CId ,
SUM(CASE 
	WHEN score>60 THEN
		1
	ELSE
		0
END
) / count(1) AS 及格率
FROM
SC
GROUP BY CId


#15 按各科成绩进行排序，并显示排名，score重复时合并名次 @rank设置变量进行排序

SELECT
 SId,CId,score,
 CASE 
	WHEN (@sco=score) THEN @rank
	ELSE @rank:=@rank+1 end as rn,
 @sco:=score
FROM
SC, (SELECT @rank:=0,@sco:=0) as t
ORDER BY score DESC


