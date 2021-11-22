db = db.getSiblingDb("phpmongoadmin");
db.createCollection("mongoadmintest");
db.mongoadmintest.insertOne(
    {test:"Test inserted"}
);
