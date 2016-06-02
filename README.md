# vertdump
Dumps HP Vertica database tables to zip file


### How to use (as root):

```
git clone https://github.com/gleisonsilva/vertdump.git
cd vertdump
```

### Exporting data
```
./vertdump.sh -e DB_ADMIN_USER DB_ADMIN_PASSWORD SCHEMA_NAME /tmp/export/
```
    
### Importing data
```
Tip : check in /tmp/export/ if there is a file used to import data previously . If any, should be deleted

./vertdump.sh -i DB_ADMIN_USER DB_ADMIN_PASSWORD SCHEMA_NAME ZIPPED_DUMP_FILE_TO_IMPORT USER_OWNER_OF_THE_IMPORTED_SCHEMA
```