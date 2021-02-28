- hive分桶，根据分桶的字段把数据划分到不同的文件中，取决于reduce的数量（类似mr中的分区）
  - desc formatted tablename; //Num buckets显示分桶信息
  - 实现：
  ```sql
  create table test_buck(id int,name string)
  clustered by(id) sorted by (id asc) into 6 buckets
  row format delimited fields terminated by '\t';
  ```
  - 如何向一个分桶表添加数据
  ```
  直接通过load data加载不行，无法分桶
  现在又一个文件，如何添加到分桶表
  1.先定义一个临时表，此表和分桶表有相同的字段，只不过不是分桶表
  2.将数据通过 load data的方式加载到临时表中
  3.最后通过insert into查询临时表，灌入分桶表
  4.限制桶表执行load set hive.strict.checks.bucketing=true;
  ```
  - 作用：
    - 数据采样
      - 数据量庞大
      - 校验数据结构，可行性
      - 计算相对比例，不需要十分精确
      - 操作
      ```
      select * from table tablesample(bucket x out of y on column) as a;  注意别名要在采样前
      抽样函数tablesample(bucket x out of y on column)
      x：从第几个桶开始抽样
      y:抽样比例，此值必须为桶数量的倍数或者因子
      案例说明：user表是一个分桶表，共分为10个桶
      select * from user tablesample(bucket 2 out of 2 on column);
      抽取一个桶 10/2=5
      抽取第2,4,6,8,10个桶： x=2
      ```
    - 提升查询效率
      - 提升原因：
        - 配置完分桶后hdfs会根据某些配置如取余将文件分为多个文件如根据年龄age，下次查询根据输入条件年龄大小会直接到对应的文件找
        - 执行效率在多表关联时表现更佳
        - 多表join的优化操作：
          - 小表大表
            - 正常的join操作,会进行分区后在reduce端进行
            - 操作后可以设置到map端进行join
            ```
            set hive.auto.convert.join=true 自动尝试map join
            set hive.auto.cnovert.noconditionaltask.size=512000000 小表判断 ，默认为20m超过20m之后只会在reduce中进行
            ```
          - 中表大表
            - 
          - 大表大表
            - SMB map join (sort merge bucket map join)
            - 使用条件：
            ```properties
            1.两个桶表 set hive.enforce.bucketing=true;
            2.set hive.auto.convert.join=true;
            3.set hive.optimize.bucketmapjoin = true; 开启
            4.set hive.optimize.bucketmapjoin=true; 开启bucket mapjoin
            5.set hive.auto.convert.sortmerge.join=true;
            6.set hive.optimize.bucketmapjoin.sortmerge.join = true; 开启smb join
            7.set hive.auto.convert.sortmerge.join.noconditionaltask=true ; 自动尝试smb连接
            8.两个表桶数相等
            9.bucket列 == join列 == sort列
            10.必须是应用在bucket map join场景中
            11.执行顺序 先判断是否可以smbjoin,再判断是否可以bucket map join ，最后都不行就走reduce join
            
            ```
          
