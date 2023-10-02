-------- PostgreSQL チュートリアル --------------------------------
/*
学習内容をまとめるためのファイルである。

PostgreSQLチュートリアル：https://www.postgresql.jp/document/15/html/tutorial.html
インストール：https://www.postgresql.jp/document/15/html/install-binaries.html：

wiki：https://wiki.postgresql.org/wiki/Main_Page/ja
サイト：https://www.postgresql.org/

コメントアウトの後に`;`が置かれているのは、VSCodeのハイライトを適切に区切るためのものである。
*/
;

/*【PostgreSQLとは】
オブジェクトリレーショナルデータベース管理システム（ORDBMS）

標準SQL：
* 複雑な問い合わせ
* 外部キー
* トリガ
* 更新可能ビュー？
* トランザクションの一貫性？
* 多版同時実行制御？

PosgreSQLの新規機能：
* データ型
* 関数
* 演算子
* 集約関数
* インデックスメソッド
* 手続き言語

*/

/*【構造的な基礎事項】
PostgreSQLはクライアント/サーバモデルを採用。
２つのプロセス（プログラム）で構成される。
1. サーバプロセス：
    データベースファイルを管理し、クライアントに代わってデータベースに対して処理を行う。
2. クライアント（フロントエンド）アプリケーション：https://www.postgresql.jp/document/15/html/reference-client.html
    ユーザがデータベース操作を行うためのアプリケーション。

* PostgreSQLサーバは"fork"によってクライアントからの同時接続を扱う。

* 
*/
;

-------- メタデータの管理 ------------------------------------------------
;
/*【ユーザの作成】
https://www.postgresql.jp/document/15/html/sql-commands.html

管理者権限を用いて、試用するユーザ・グループを作成する。

PostgreSQLクライアントアプリケーションを使う方法もある：
https://www.postgresql.jp/document/15/html/reference-client.html
*/
;


/*
CREATE GROUP : グループの作成 : https://www.postgresql.jp/document/15/html/sql-creategroup.html
・追加・権限付与・削除にはALTER, GRANT, DROPを用いる
・標準SQLにGROUPはないが、roleが似ている
*/
CREATE GROUP beginer;


/* 
CREATE USER : データベースユーザの追加 : https://www.postgresql.jp/document/8.0/html/user-manag.html
1. データベーススーパーユーザ：権限検査が無い。新しいユーザを追加できる。
2. CRATEDB : データベース作成の権限がある

*/
-- createuser user_name 
CREATE USER user_name WITH 
    CREATEDB 
    IN GROUP beginer 
    PASSWORD 'passward' ;


/*
CREATE DATABASE : データベースの作成
`createbd tutorial`でも可
*/
CREATE DATABASE tutorial;

-- 権限付与
GRANT ALL ON DATABASE tutorial TO beginer;



-- サーバーに入る：`psql tutorial` or `psql -d tutorial -U user_name`
;
-- PostgreSQLのバージョン確認
SELECT version(); 
-- ヘルプ
\h
;
-- 終了
\q
;





-------- SQL言語 -------------------------------------------------
;
/*
リレーショナルデータベース管理システム：リレーションの中に格納されたデータを管理するシステム。

データの集まりとして、次のように階層が分かれている：
    テーブル　∊　データベース　∊　データベースクラスタ
データベースクラスタはPostgreSQLサーバインスタンスで管理される。
*/
;
-- コマンド一覧： https://www.postgresql.jp/document/15/html/sql-commands.html
;
/*
CREATE TABLE : リレーションの作成 
属性名とドメインの組として定義される。

1. SQL datatypes : 
      int, smallint, real, double precision, 
      char(N), varchar(N), 
      date, time, timestamp, interval, 
2. PostgreSQL datatypes : point
*/
CREATE TABLE weather (
    city varchar(80), -- 都市名
    temp_lo int, -- 最高気温
    temp_hi int, -- 最高気温
    prcp real, -- 降水量
    date date -- 日付
);

CREATE TABLE cities (
    name varchar(80), -- 名前
    location point -- 座標
);



-- 参照整合性の保全：一致する項目が無い行に挿入をしない。
-- 主キー宣言：primary key
CREATE TABLE cities (
        name     varchar(80) primary key, -- 主キーの宣言
        location point
);

-- 外部キー制約：references
CREATE TABLE weather (
        city      varchar(80) references cities(name), -- 外部キー宣言
        temp_lo   int,
        temp_hi   int,
        prcp      real,
        date      date
);



-------- insert coloms into table ------------------------------
-- 挿入
INSERT INTO weather (city, temp_lo, temp_hi, prcp, date)
    VALUES ('San Francisco', 43, 57, 0.0, '1994-11-29');

-- 一部が分からなくても作成できる
INSERT INTO weather (date, city, temp_hi, temp_lo)
    VALUES ('1994-11-29', 'Hayward', 54, 37);

-- 順番を覚えていればに省略できるが、好まれない。
INSERT INTO weather VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27');

-- point型の入力には座標の組み合わせが必要
INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');


-- COPY : 高速にロード : バックエンドプロセスがこのファイルを読み込む
COPY weather FROM '/home/user/weather.txt';



---- SELECT : 取り出し
-- 射影の例
SELECT city, temp_lo, temp_hi, prcp, date FROM weather;

-- "*" : 全ての列を表す。即興的な問い合わせで有用だが、テーブルに列を追加ことで結果が異ない。れない。まな
SELECT * FROM weather;  

-- AS : 式を指定し、新しい列を追加できる
SELECT city, (temp_hi+temp_lo)/2 AS temp_avg, date 
    FROM weather;

-- WHERE : 論理式を使って条件で絞れる。
SELECT * FROM weather
    WHERE city = 'San Francisco' AND prcp > 0.0;
    
-- ORDER BY : ソートで返す
SELECT * FROM weather
    ORDER BY city;
SELECT * FROM weather
    ORDER BY city, temp_lo;

-- DISTINCT : 重複を除く
SELECT DISTINCT city FROM weather
    ORDER BY city;



---- [INNER] JOIN : （内部）結合
-- 等結合の例。`cities`に記述の無い`Hayward`は除かれる。
SELECT * 
    FROM weather JOIN cities ON city = name;

-- 自然結合を実現するには、出力を明示的に指定する。
SELECT city, temp_lo, temp_hi, prcp, date, location
    FROM weather JOIN cities ON city = name;

-- （今回は必要ないが、）リレーション間で属性名が重複する場合、属性名を明示的に修飾する。
SELECT weather.city, weather.temp_lo, weather.temp_hi,
       weather.prcp, weather.date, cities.location
    FROM weather JOIN cities ON weather.city = cities.name;



---- [OUTER] JOIN : 外部結合：null値を認める結合
-- LERT : テーブルの左側の値と一致するものが無い場合、null値を用いた行を結合する。
SELECT *
    FROM weather LEFT OUTER JOIN cities ON weather.city = cities.name;

-- RIGHT : テーブルの左側の要素が不足している場合、左側の行にnull値を用いて追加される。
SELECT *
    FROM cities RIGHT OUTER JOIN weather ON weather.city = cities.name;

-- FULL : 一致しなかった値にnullを用いtえ返す。
SELECT *
    FROM cities FULL OUTER JOIN weather ON weather.city = cities.name;

-- 自己結合：自身の行を結合する。
--例：最低気温が高く，最高気温が低いデータの自己結合
SELECT w1.city, w1.temp_lo AS low, w1.temp_hi AS high,
       w2.city, w2.temp_lo AS low, w2.temp_hi AS high
    FROM weather w1 JOIN weather w2
        ON w1.temp_lo < w2.temp_lo AND w1.temp_hi > w2.temp_hi;

-- 別名を用いた問い合わせ
SELECT *
    FROM weather w JOIN cities c ON w.city = c.name;



/*
上記にある問い合わせ
SELECT * 
    FROM weather JOIN cities ON city = name;
を簡略化するための、ビューを導入する。
*/
-- VIEW : 物理的実体ではなく、問い合わせによるビュー
CREATE VIEW tutoview AS
    SELECT name, temp_lo, temp_hi, prcp, date, location
        FROM weather, cities
        WHERE city = name;

SELECT * FROM tutoview;



---- 集約関数
SELECT max(temp_lo) FROM weather;

-- GROUP BY : 特定の属性に対して集約関数を適用する
SELECT city, count(*), max(temp_lo)
    FROM weather
    GROUP BY city;

-- HAVING : グループ化した行に対してフィルタをかける
SELECT city, count(*), max(temp_lo)
    FROM weather
    GROUP BY city
    HAVING max(temp_lo) < 40;

-- LINE : 正規表現による文字列のフィルタ
-- https://www.postgresql.jp/document/15/html/functions-matching.html
SELECT city, count(*), max(temp_lo)
    FROM weather
    WHERE city LIKE 'S%'            -- (1)
    GROUP BY city;

-- FILTER : 集約関数に対するオプション
SELECT city, count(*) FILTER (WHERE temp_lo < 45), max(temp_lo)
    FROM weather
    GROUP BY city;

/*
where : グループや集約を計算する前に、入力行を選択：集約関数を持てない。
HAVING :  集約を計算した後に、グループ化された行を選択すrう。：常に主役関数を持つ。
*/
-- 集約関数を用いた問い合わせは、副問い合わせを用いて行う。
SELECT city FROM weather
    WHERE temp_lo = (SELECT max(temp_lo) FROM weather);

    
-- UPDATE : 更新
UPDATE weather
    SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2
    WHERE date > '1994-11-28';

-- DELETE : 削除
DELETE FROM weather WHERE city = 'Hayward';



-- トランザクション：トランザクションに登録した一連の手順を完結した場合のみにCOMMITし、そうでない場合はROLLBACKによって全ての更新を破棄する
-- トランザクションブロックの内部は他のデータベースセッションからは見えず、コミットされた行為が1つの単位に見える。
-- 例：Aiceの講座からBobの口座に$100.00の送金を記録する。
/*
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE branches SET balance = balance - 100.00
    WHERE name = (SELECT branch_name FROM accounts WHERE name = 'Alice');
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
UPDATE branches SET balance = balance + 100.00
    WHERE name = (SELECT branch_name FROM accounts WHERE name = 'Bob');
-- 等々
COMMIT;
*/;

-- セーブポイント：
/*
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';

-- おっと、忘れるところだった。ウィリーの口座を使わなければ。
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;
*/;


