select room_tasks.*,
         room_name,
         task_name,
         COALESCE(max(end_datetime), DateTime('now', 'localtime', '-30 days')) as most_recent_cleaning,
         string_agg(equipment_name,
         ';')
         from room_tasks, rooms, tasks, task_equipment, equipment
         left join cleanings on room_tasks.id = cleanings.room_tasks_id
         where room_tasks.room_id=rooms.id
           and room_tasks.task_id=tasks.id
           and task_equipment.task_id=tasks.id
           and task_equipment.equipment_id=equipment.id
           and (cleanings.is_real=1 or cleanings.is_real is null)
         group by room_tasks.id
         order by room_name, task_name;


select * from cleanings where room_tasks_id='27e415f0'
delete from cleanings where id='891e5f0'

select * from rooms
delete from rooms where id='05ff261c'
delete from room_tasks where room_id='05ff261c'
3d948932
09a7ea05

select * from cleanings
delete from cleanings where id in ('7094dd0',
'ad83e50',
'546d630',
'53079c0',
'fcf2250',
'2fd6600')

update room_tasks set period_days = 180 where id='f79bd867'

create table rooms (
id varchar(50) primary key,
user_id varchar(50) not null,
name varchar(250) not null
);

create table tasks (
id varchar(50) primary key,
room_id varchar(50) not null,
task_name varchar(250) not null
);

create table room_tasks (
id varchar(50) primary key,
room_id varchar(50) not null,
task_id varchar(250) not null
);

select * from cleanings where is_real=0;
delete from cleanings where is_real=0

select room_tasks.*, room_name, task_name, period_days from room_tasks, rooms, tasks
where room_tasks.room_id=rooms.id
and room_tasks.task_id=tasks.id;

alter table room_tasks add column period_days int

create table equipment
(id varchar(50) primary key,
equipment_name varchar(250))

insert into equipment values
(	'22e1f9e6',	'equipment'),
(	'25fae5ec',	'vacuum'),
(	'8bcf6379',	'duster'),
(	'9821579a',	'cleaning spray and rags'),
(	'a589d758',	'broom and dustpan'),
(	'f8bba2be',	'window spray and rag'),
(	'324e5cb5',	'cleaning spray and scrub brush'),
(	'126bbd60',	'toilet brush'),
(	'a13fbffc',	'toothbrush')

select * from equipment

create table task_equipment
(id varchar(50) primary key,
task_id varchar(50),
equipment_id varchar(50))

insert into task_equipment (id, task_id, equipment_id) values
(	'cd26c9b4',	'e0982550',	'25fae5ec'),
(	'f7590b8',	'10aac6a1',	'25fae5ec'),
(	'91eea7b8',	'5fd96b7d',	'8bcf6379'),
(	'32f7bc4',	'4f508139',	'8bcf6379'),
(	'7172ba08',	'eaac4cd8',	'a589d758'),
(	'be9d7fe',	'be762c8c',	'a589d758'),
(	'c8fb408c',	'c423a2e8',	'324e5cb5'),
(	'ce9bb370',	'bf0a491d',	'324e5cb5'),
(	'7c7b5007',	'f69da72c',	'9821579a'),
(	'4adf6b40',	'bb441880',	'324e5cb5'),
(	'6e0a493',	'ef2897ad',	'9821579a'),
(	'9558e5f8',	'e0a60121',	'324e5cb5'),
(	'83db0cab',	'091f7509',	'324e5cb5'),
(	'c83afc08',	'417d98a2',	'324e5cb5'),
(	'1c31e5bb',	'af657682',	'9821579a'),
(	'a4a9a52b',	'10aac6a1',	'a589d758'),
(	'14315977',	'ef2897ad',	'126bbd60'),
(	'd57bb535',	'af657682',	'a13fbffc')

update room_tasks set period_days=90 where id in
('f79bd867',
'25b71ba3',
'084fa62e',
'5ac2712d',
'13d59c88',
'4bb0b6bc',
'ca570acf')


create table cleanings (
id varchar(50) primary key,
room_tasks_id varchar(50),
start_datetime datetime,
end_datetime datetime
)

alter table room_tasks add primary key (id);

create table room_tasks2
(id varchar(50) primary key,
task_id varchar(50),
room_id varchar(50),
description varchar(250),
period_days int
)

alter table cleanings rename column start_datetime to end_datetime;
alter table cleanings add column duration_ms int;

select * from cleanings;
delete from cleanings;

insert into room_tasks2 select * from room_tasks
alter table room_tasks2 rename to room_tasks;

select room_tasks.*, room_name, task_name, COALESCE(max(end_datetime), DateTime('now', 'localtime', '-6 month')) as most_recent_cleaning, string_agg(equipment_name, ';')
from room_tasks, rooms, tasks, task_equipment, equipment
left join cleanings on room_tasks.id = cleanings.room_tasks_id
where room_tasks.room_id=rooms.id and room_tasks.task_id=tasks.id and task_equipment.task_id=tasks.id and task_equipment.equipment_id=equipment.id
group by room_tasks.id
order by room_name, task_name;

select room_tasks.*, room_name, task_name, COALESCE(max(end_datetime), DateTime('now', 'localtime', '-6 month')) as most_recent_cleaning, string_agg(equipment_name, ';')
from room_tasks, rooms, tasks, task_equipment, equipment
right join cleanings on room_tasks.id = cleanings.room_tasks_id
where room_tasks.room_id=rooms.id and room_tasks.task_id=tasks.id and task_equipment.task_id=tasks.id and task_equipment.equipment_id=equipment.id
group by room_tasks.id
order by room_name, task_name;

update room_tasks set period_days = 5 where period_days = 4;
update room_tasks set period_days = 4 where period_days = 3;




select room_tasks.id, max(end_datetime) as most_recent_cleaning
from cleanings
group by room_tasks.id


select room_tasks.id,  max(end_datetime) as most_recent_cleaning
from room_tasks, cleanings
where room_tasks.id = cleanings.room_tasks_id
group by room_tasks_id

select * from room_tasks where id like '6c%'

insert into cleanings values

insert into cleanings values ('abc', '6c8fb604', DateTime('now', 'localtime'), DateTime('now', 'localtime', '+5 minute'))



delete from room_tasks where id in
('6c8fb604',
'17996874',
'8335e94c',
'f05e9041',
'b270ca1d',
'61119117',
'6c4c0ce1',
'1a4883e6',
'a78b5767',
'6a54e5c5',
'c91257c6',
'b22c4c71',
'46724582',
'a13cdc91',
'a4031a22',
'4098b488',
'4e2b1741',
'3ec67a61',
'37d98847',
'19926652',
'b94aa45a',
'4df52a3e',
'8145c5ee',
'00d7ff3e',
'f87e6f96',
'c9529718',
'ae5ac6c2',
'4157bf4d',
'2d890fc9',
'a4fdd4ab')

create table room_tasks as
select substr(lower(hex(randomblob(16))), 1, 8) as id, tasks.id as task_id, rooms.id as room_id, '' as description from tasks, rooms

alter table tasks drop column task_id

insert into rooms (id, user_id, room_name) values
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'living room'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'kitchen'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'bedroom 1'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'bedroom 2'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'bathroom'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'hall'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'hall closet'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'entryway'),
(substr(lower(hex(randomblob(16))), 1, 8), '1', 'deck');

select * from tasks;
truncate tasks;
delete from rooms;

insert into tasks (id, task_name) values
(substr(lower(hex(randomblob(16))), 1, 8), 'quick vacuum'),
(substr(lower(hex(randomblob(16))), 1, 8), 'deep vacuum'),
(substr(lower(hex(randomblob(16))), 1, 8), 'quick dust'),
(substr(lower(hex(randomblob(16))), 1, 8), 'deep dust'),
(substr(lower(hex(randomblob(16))), 1, 8), 'quick sweep'),
(substr(lower(hex(randomblob(16))), 1, 8), 'deep sweep'),
(substr(lower(hex(randomblob(16))), 1, 8), 'ceiling scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'floor scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'counter and table scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'sink scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'toilet scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'mirror scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'quick window scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'deep window scrub'),
(substr(lower(hex(randomblob(16))), 1, 8), 'handles and switches scrub');

insert into rooms (id, user_id, room_name) values
('f45ed054', '1', 'living room'),
('39308d94', '1', 'kitchen'),
('c7f3cf68', '1', 'bedroom 1'),
('c67104b4', '1', 'bedroom 2'),
('b17e8c4b', '1', 'bathroom'),
('60110436', '1', 'hall'),
('3381d43b', '1', 'hall closet'),
('f14b308c', '1', 'entryway'),
('b216af02', '1', 'deck');


select lower(hex(randomblob(16))) as task_id, id as room_id, 'vacuum middle' as task from rooms;
