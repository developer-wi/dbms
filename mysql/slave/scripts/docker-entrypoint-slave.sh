#!/bin/bash
set -e

sleep 5
# (1)
until mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" -h ${MYSQL_MASTER_HOST}  -P ${MYSQL_MASTER_PORT}  ping; do
  echo "# waiting for master - $(date)"
  sleep 3
done

# (2)
#mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER 'replUser'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}'"
# mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'replUser'@'%' WITH GRANT OPTION"
#mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES"

# (3)
source_log_file=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h ${MYSQL_MASTER_HOST} -P ${MYSQL_MASTER_PORT} -e "SHOW MASTER STATUS\G" | grep mysql-bin)
re="[a-z]*-bin.[0-9]*"
if [[ $source_log_file =~ $re ]];then
  source_log_file=${BASH_REMATCH[0]}
fi

# (4)
source_log_pos=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h ${MYSQL_MASTER_HOST} -P ${MYSQL_MASTER_PORT} -e "SHOW MASTER STATUS\G" | grep Position)
re="[0-9]+"
if [[ $source_log_pos =~ $re ]];then
  source_log_pos=${BASH_REMATCH[0]}
fi


# (5) 포트를 내부포트로 사용해야 정상 연결 됨
sql="CHANGE MASTER TO MASTER_HOST='${MYSQL_MASTER_HOST}',MASTER_PORT=${MYSQL_MASTER_PORT}, MASTER_USER='${MYSQL_REPL_USER_ID}', MASTER_PASSWORD='${MYSQL_REPL_USER_PASSWORD}', MASTER_LOG_FILE='${source_log_file}', MASTER_LOG_POS=${source_log_pos}"


mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "STOP SLAVE"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "${sql}"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "START SLAVE"

sleep 3

# slave가 여러개 일 경우 마지막에 한번만 실행
# (6)데이터베이스 생성
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h ${MYSQL_MASTER_HOST} -P ${MYSQL_MASTER_PORT} -e "CREATE DATABASE ${MYSQL_DB}"

# (7) 사용자 계정 생성 및 권한 할당
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h ${MYSQL_MASTER_HOST} -P ${MYSQL_MASTER_PORT} -e "CREATE USER '${MYSQL_USER_ID}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}'"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h ${MYSQL_MASTER_HOST} -P ${MYSQL_MASTER_PORT} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER_ID}'@'%' WITH GRANT OPTION"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h ${MYSQL_MASTER_HOST} -P ${MYSQL_MASTER_PORT} -e "FLUSH PRIVILEGES"