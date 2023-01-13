import mysql.connector
from mysql.connector import Error

""""" LOCALHOST DATABASE CONNECTION """""
try:
    database = mysql.connector.connect(
        host = "localhost",
        port = "3306",
        user = "dp_test",
        password = "DpPythonTest1*_",
        database = "distributors"
    )

    if database.is_connected():
        print("Conexión exitosa")

except Error as ex:
    print("Error durante la conexión: ", ex)


""""" REMOTE SERVER CONNECTION
try:
    database = mysql.connector.connect(
        host = "mysql-104308-0.cloudclusters.net",
        user = "admin",
        port = "10197",
        password = "n1sUHfKc",
        database = "distributors"
    )

    if database.is_connected():
        print("Conexión exitosa")

except Error as ex:
    print("Error durante la conexión: ", ex)
"""""