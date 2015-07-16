#!/bin/bash

# exemplo de uso:
#    /vagrant/vertdump.sh -e dbadmin dw crdw /tmp/export
#   onde dw é a senha do database

# TODO:
#   - Remover o path antes de zipar para que não precise usar o caminho /tmp/export
#   - Permitir trocar o schema de destino antes de importar
#   - Solicitar a senha como prompt para nao precisar expo-la no bash history

vsql=/opt/vertica/bin/vsql
act=$1
user=$2
pass=$3
schema=$4
dest_dir=$5
file=$5

function usage {
  echo ' USAGE: '
  echo '    ./vertdump { -i | -e } user pass schema dest_dir'
}

function exp {
  stmt_tables="select table_name \
      from ( \
          select tables.table_name, count(table_constraints.constraint_id) dep_count \
          from v_catalog.tables left join v_catalog.table_constraints on \
            table_constraints.foreign_table_id = tables.table_id \
          where table_schema='$schema' and is_system_table = false group by 1 \
      ) as t \
      order by dep_count desc"

  echo 'Starting export...';
  mkdir $dest_dir -p;
  chmod 777 $dest_dir

  echo '   Exporting catalog to dir $dest_dir...';
  $vsql -U $user -w $pass -F $'|' -At -c "SELECT export_catalog('$dest_dir/catalog_export.sql','DESIGN')";
  
  if [ "$?" -ne "0" ]; then
    echo "   exporting catalog failed."
    exit 1
  fi

  echo '   Exporting table data...';
  for t in `$vsql -U $user -w $pass -F $'|' -At -c "$stmt_tables"`; do (
      echo Exporting table $t; 
      a=`date +%H%M%S`;
      $vsql -U $user -w $pass -F $'|' -At -c "SELECT * FROM $schema.$t" | gzip -c > $dest_dir'/'$a'-'$t'.gz';
  ) done 

  if [ "$?" -ne "0" ]; then
    echo "   exporting table data failed."
    exit 1
  fi

  echo '   Compressing destination dir...';
  tar -czvf $schema.tar.gz $dest_dir
  rm -rf $dest_dir
  exit
}

function imp {
  echo 'Starting import of data...';
  
  echo '   uncompressing file $file to /...'
  tar zxvf $file -C /
  
  if [ "$?" -ne "0" ]; then
    echo "     uncompressing failed."
    exit 1
  fi

  echo '   creating table structures...'
  $vsql -U $user -w $pass -f /tmp/export/catalog_export.sql

  echo '   importing table data...'
  for t in `ls /tmp/export/*.gz`; do (
      tbl=`echo $t | awk -F "-" '{print $2}'`;
      tbl=`echo $tbl | awk -F "." '{print $1}'`;
      echo Importing $tbl; 
      $vsql -U $user -w $pass -c "truncate table $schema.$tbl;"
      $vsql -U $user -w $pass -c "COPY $schema.$tbl FROM '$t' GZIP DELIMITER '|';"
      $vsql -U $user -w $pass -c "alter table $schema.$tbl owner to $schema"
  ) done 

  exit
}

case $act in
  "-e")
    exp
    ;;
  "-i") 
    imp
    ;;
  "-h") 
    usage
    ;;
esac