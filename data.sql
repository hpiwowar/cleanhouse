-- cleanings definition

CREATE TABLE cleanings (
id varchar(50) primary key, 
room_tasks_id varchar(50), 
end_datetime datetime, 
duration_ms int);

;


-- equipment definition

CREATE TABLE equipment 
(id varchar(50) primary key, 
equipment_name varchar(250));

;


-- room_tasks definition

CREATE TABLE "room_tasks" 
(id varchar(50) primary key, 
task_id varchar(50),
room_id varchar(50),
description varchar(250),
period_days int
);

;


-- rooms definition

CREATE TABLE rooms (
id varchar(50) primary key,
user_id varchar(50) not null, 
room_name varchar(250) not null
);

;


-- task_equipment definition

CREATE TABLE task_equipment 
(id varchar(50) primary key, 
task_id varchar(50),
equipment_id varchar(50));

;


-- tasks definition

CREATE TABLE tasks (
id varchar(50) primary key,
task_name varchar(250) not null
, description varchar(512));

;


INSERT INTO tasks (id,task_name,description) VALUES
	 ('e0982550','quick vacuum',NULL),
	 ('10aac6a1','deep vacuum',NULL),
	 ('5fd96b7d','quick dust',NULL),
	 ('4f508139','deep dust',NULL),
	 ('eaac4cd8','quick sweep',NULL),
	 ('be762c8c','deep sweep',NULL),
	 ('c423a2e8','ceiling scrub',NULL),
	 ('bf0a491d','floor scrub',NULL),
	 ('f69da72c','counter and table scrub',NULL),
	 ('bb441880','sink scrub',NULL),
	 ('ef2897ad','toilet scrub',NULL),
	 ('e0a60121','mirror scrub',NULL),
	 ('091f7509','quick window scrub',NULL),
	 ('417d98a2','deep window scrub',NULL),
	 ('af657682','handles and switches scrub',NULL);

INSERT INTO task_equipment (id,task_id,equipment_id) VALUES
	 ('cd26c9b4','e0982550','25fae5ec'),
	 ('f7590b8','10aac6a1','25fae5ec'),
	 ('91eea7b8','5fd96b7d','8bcf6379'),
	 ('32f7bc4','4f508139','8bcf6379'),
	 ('7172ba08','eaac4cd8','a589d758'),
	 ('be9d7fe','be762c8c','a589d758'),
	 ('c8fb408c','c423a2e8','324e5cb5'),
	 ('ce9bb370','bf0a491d','324e5cb5'),
	 ('7c7b5007','f69da72c','9821579a'),
	 ('4adf6b40','bb441880','324e5cb5'),
	 ('6e0a493','ef2897ad','9821579a'),
	 ('9558e5f8','e0a60121','324e5cb5'),
	 ('83db0cab','091f7509','324e5cb5'),
	 ('c83afc08','417d98a2','324e5cb5'),
	 ('1c31e5bb','af657682','9821579a'),
	 ('a4a9a52b','10aac6a1','a589d758'),
	 ('14315977','ef2897ad','126bbd60'),
	 ('d57bb535','af657682','a13fbffc');

INSERT INTO rooms (id,user_id,room_name) VALUES
	 ('b8585499','1','living room'),
	 ('63b6d0be','1','kitchen'),
	 ('13a5bebf','1','bedroom 1'),
	 ('8e4fc56d','1','bedroom 2'),
	 ('3f351625','1','bathroom'),
	 ('05ff261c','1','hall'),
	 ('b9594ae4','1','hall closet'),
	 ('3628fead','1','entryway'),
	 ('3a3d6145','1','deck');

INSERT INTO room_tasks (id,task_id,room_id,description,period_days) VALUES
	 ('3d948932','10aac6a1','05ff261c','',30),
	 ('09a7ea05','af657682','05ff261c','',30),
	 ('85556a9b','e0982550','05ff261c','',4),
	 ('f8552b34','091f7509','13a5bebf','',30),
	 ('d6155e15','10aac6a1','13a5bebf','',30),
	 ('25b71ba3','417d98a2','13a5bebf','',90),
	 ('14aca799','4f508139','13a5bebf','',60),
	 ('399eacfb','5fd96b7d','13a5bebf','',14),
	 ('b39a9758','af657682','13a5bebf','',60),
	 ('028ee367','e0982550','13a5bebf','',4),
	 ('09b24792','af657682','3628fead','',30),
	 ('b0ed3800','be762c8c','3628fead','',7),
	 ('ca423976','e0982550','3628fead','',4),
	 ('cf6f8080','091f7509','3a3d6145','',30),
	 ('084fa62e','417d98a2','3a3d6145','',90),
	 ('47b505ff','be762c8c','3a3d6145','',60),
	 ('4bb0b6bc','bf0a491d','3a3d6145','',90),
	 ('a893be77','091f7509','3f351625','',5),
	 ('c79a7826','417d98a2','3f351625','',14),
	 ('bbf27001','af657682','3f351625','',30),
	 ('60762922','bb441880','3f351625','',4),
	 ('71cc968f','be762c8c','3f351625','',5),
	 ('94903bdf','bf0a491d','3f351625','',7),
	 ('8f972e2d','c423a2e8','3f351625','',60),
	 ('fd95e1bc','e0a60121','3f351625','',4),
	 ('d7e55ac1','eaac4cd8','3f351625','',4),
	 ('d0a36d9c','ef2897ad','3f351625','',3),
	 ('c2f04e0e','f69da72c','3f351625','',4),
	 ('5b5b2034','af657682','63b6d0be','',30),
	 ('6dedb0e5','bb441880','63b6d0be','',4),
	 ('3a025d7a','be762c8c','63b6d0be','',5),
	 ('81dd7c91','bf0a491d','63b6d0be','',7),
	 ('ca570acf','c423a2e8','63b6d0be','',90),
	 ('efc61400','eaac4cd8','63b6d0be','',4),
	 ('eafb4136','f69da72c','63b6d0be','',4),
	 ('209d478a','091f7509','8e4fc56d','',30),
	 ('27e415f0','10aac6a1','8e4fc56d','',30),
	 ('5ac2712d','417d98a2','8e4fc56d','',90),
	 ('aea30208','4f508139','8e4fc56d','',60),
	 ('0eb38e54','5fd96b7d','8e4fc56d','',14),
	 ('1a55b93c','af657682','8e4fc56d','',60),
	 ('8ab9906a','e0982550','8e4fc56d','',4),
	 ('6746babc','091f7509','b8585499','',30),
	 ('df81820e','10aac6a1','b8585499','',30),
	 ('13d59c88','417d98a2','b8585499','',90),
	 ('e2dfcc6a','4f508139','b8585499','',30),
	 ('5959aa17','5fd96b7d','b8585499','',7),
	 ('51ac4691','af657682','b8585499','',30),
	 ('34eab0c8','e0982550','b8585499','',2),
	 ('fbd538f2','f69da72c','b8585499','',4),
	 ('f79bd867','10aac6a1','b9594ae4','',90);

INSERT INTO equipment (id,equipment_name) VALUES
	 ('22e1f9e6','equipment'),
	 ('25fae5ec','vacuum'),
	 ('8bcf6379','duster'),
	 ('9821579a','cleaning spray and rags'),
	 ('a589d758','broom and dustpan'),
	 ('f8bba2be','window spray and rag'),
	 ('324e5cb5','cleaning spray and scrub brush'),
	 ('126bbd60','toilet brush'),
	 ('a13fbffc','toothbrush');

