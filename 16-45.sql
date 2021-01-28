#笔记17 select 中使用 sum(case when xx then 1 else 0) 即可统计
####### 模糊 笔记18 orderby是可以叠加使用的 ，where条件中可以使用(SELECT count(1) from SC b WHERE b.cid=a.cid and b.score>a.score) < 3
#笔记20 当sid和sname都指向同一人，groupby可以同时分类sid和sname
#笔记23 count中可以使用distinct记录sid，另外正是因为使用了and,进行合并搜索得到的内容才可以用groupby来再次分组
#24 where year('1990-09-09')
#25 升序asc
# 17搜索成绩范围的人数
#33 orderby desc配合limit查询出前n条数据
########## 42
#43 week('yyyy-mm-dd')得出该日在该年第几周与year同理可以传入一个now()
SELECT CId,
sum(CASE 
	WHEN score<60 THEN
		1
	ELSE
		0
END
)
FROM
SC
GROUP BY CId


#18 搜索各科成绩前3的信息



#19查询每门课有多少人修
SELECT CId,COUNT(1)
FROM
SC 
GROUP BY
CId


#20查询只修了两门课程的学生学号和姓名
SELECT a.SId,b.Sname
FROM
SC a
INNER JOIN
Student b
ON a.SId=b.SId
GROUP BY a.SId,b.Sname
HAVING COUNT(1)=2

#23 查询同名同性学生人数
#查询同名同性学生人数
SELECT a.Sname,a.Ssex,
COUNT(DISTINCT a.SId)
FROM Student a
INNER JOIN
Student b
ON a.Sname=b.Sname AND a.Ssex=b.Ssex AND a.SId<>b.SId
GROUP BY a.Sname,a.Ssex


#33成绩不重复，查询选秀张三老师所授课程中成绩最高的学生信息
SELECT  a.CId,a.Cname,a.TId,c.SId,c.score,d.Sname
FROM
Course a
INNER JOIN
Teacher b
INNER JOIN
SC c
INNER JOIN
Student d
ON a.TId=b.TId
AND b.Tname='张三'
AND c.CId=a.CId
AND d.SId=c.SId
ORDER BY c.score DESC
LIMIT 2


