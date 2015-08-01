# vertdump
Dumps HP Vertica database tables to zip file


### How to use (as root):

```
git clone https://github.com/gleisonsilva/vertdump.git
cd vertdump
```

### Exporting data
```
./vertdump.sh -e DB_ADMIN_USER DATABASE_NAME SCHEMA_NAME
```
    
### Importing data
```
./vertdump.sh -i DB_ADMIN_USER DATABASE_NAME SCHEMA_NAME ZIPPED_DUMP_FILE_TO_IMPORT
```