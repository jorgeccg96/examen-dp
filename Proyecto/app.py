from flask import Flask, render_template, request, redirect, url_for
import os
from mysql.connector import Error
import database as con

# Información para las rutas
template_dir = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))
template_dir = os.path.join(template_dir, "Proyecto", "templates")
app = Flask(__name__, template_folder=template_dir)

# Ruta principal donde se muestran los datos
# Se llama a un procedimiento almacenado que busca dentro de todas las tablas
# limpia los datos y los regresa en el formato indicado
@app.route("/")
def home():
    cursor = con.database.cursor()

    cursor.callproc("get_distributors")
    distributors = []
    for result in cursor.stored_results():
        distributors = result.fetchall()

    #Convertir los datos a diccionario
    insertObject = []
    columnNames = ['person_id', 'distributor_id', 'nombre_completo', 'direccion', 'tel']

    for distributor in distributors:
        insertObject.append(dict(zip(columnNames, distributor)))
    
    cursor.close()

    return render_template("index.html", data = insertObject)

# Ruta para guardar un distribuidor
@app.route("/user", methods=["POST"])
def addDistributor():
    # Aquí recibimos los datos del formulario
    # También se definen las variables a usar
    resultId = -1
    resultMessage = ""
    resultType = ""
    identifier = request.form['identifier']
    name = request.form['name']
    middle_name = request.form['middle_name']
    paternal_surname = request.form['paternal_surname']
    maternal_surname = request.form['maternal_surname']
    calle = request.form['calle']
    numero = request.form['numero']
    colonia = request.form['colonia']
    tel = request.form['tel']

    # Se revisa que la información esté completa
    # El único campo que puede ser nulo es middle_name
    # Se llama a un procedimiento almacenado llamado add_distributor
    # El procedimiento almacenado contiene las consultas para agregar la información a todas las tablas
    # Si hay un distribuidor asociado a ese identificador se notifica del error
    # Si dicho distibuidor está inactivo se pregunta si se quiere reactivar
    if identifier and name and paternal_surname and maternal_surname and tel and calle and numero and colonia:
        cursor = con.database.cursor()
        insertDistributorQuery = "call add_distributor(%s, %s, %s, %s, %s)"
        insertDistributorData = (identifier, name, middle_name, paternal_surname, maternal_surname)
        try:
            cursor.execute(insertDistributorQuery, insertDistributorData)

            insertDistributorInfoQuery = "call add_address_tel(%s, %s, %s, %s, %s)"
            insertDistributorInfoData = (identifier, calle, numero, colonia, tel)
            cursor.execute(insertDistributorInfoQuery, insertDistributorInfoData)

            con.database.commit()
            resultType = "success"
            resultMessage = "¡Distribuidor agregado con éxito!"
        except Error as err:
            if err.errno == 1062:
                searchDistributorQuery = "SELECT distributors.estatus, CONCAT(persons.nombre, ' ', persons.apellido_paterno, ' ', persons.apellido_materno) AS `nombre_completo` FROM distributors INNER JOIN persons ON distributors.distributor_id = persons.distributor_id WHERE distributors.distributor_id = %s"
                searchDistributorData = (identifier,)

                cursor.execute(searchDistributorQuery, searchDistributorData)
                existingDistributor = cursor.fetchall()
                existingDistributorData = []
                columnNames = [column[0] for column in cursor.description]
                for record in existingDistributor:
                    existingDistributorData.append(dict(zip(columnNames, record)))

                if existingDistributorData[0]['estatus'] == 1:
                    resultType = "error"
                    resultMessage = "El identificador de usuario ya existe."
                else:
                    resultType = "borrado"
                    resultMessage = "El distribuidor ya existe ¿desea reactivarlo?"
                    resultId = identifier
            else:
                resultType = err
        cursor.close()
    else:
        resultType = "error"
        resultMessage = "Información incompleta para registro"

    return redirect(url_for("home", result = resultMessage, resultType = resultType, resultId = resultId))

# Ruta para eliminar un distribuidor
# El eliminado es lógico para no borrar datos históricos
# El borrado se hace cambiando el campo estatus de la tabla distributors a 0
@app.route("/delete/<string:id>")
def delete(id):
    cursor = con.database.cursor()
    deleteDistributorQuery = "UPDATE distributors SET `estatus`=0 WHERE distributor_id = %s;"
    deleteDistributorData = (id,)

    try:
        cursor.execute(deleteDistributorQuery, deleteDistributorData)
        con.database.commit()
        resultMessage = "Distribuidor eliminado con éxito."
        resultType = "success"
    except Error as err:
        resultMessage = "Ocurrió un error al eliminar el distribuidor."
        resultType = "error"

    cursor.close()
    return redirect(url_for("home", result = resultMessage, resultType = resultType))

# Ruta para reactivar un distribuidor
# Para reactivar un distribuidor se cambia el campo estatus de la tabla distributors a 1
@app.route("/reactivate/<string:id>")
def reactivate(id):
    cursor = con.database.cursor()
    deleteDistributorQuery = "UPDATE distributors SET `estatus`=1 WHERE distributor_id = %s;"
    deleteDistributorData = (id,)

    try:
        cursor.execute(deleteDistributorQuery, deleteDistributorData)
        con.database.commit()
        resultMessage = "Distribuidor reactivado con éxito."
        resultType = "success"
    except Error as err:
        resultMessage = "Ocurrió un error al reactivar el distribuidor."
        resultType = "error"

    cursor.close()
    return redirect(url_for("home", result = resultMessage, resultType = resultType))

# Ruta para actualizar un distribuidor.
# Se reciben los datos del formulario.
# Se crea la sentencia para actualizar los campos de address
# dependiendo de los campos ingresados.
# Si ingresas número telefónico se llama a un procedimiento almacenado
# el cual administra los datos para agregar el teléfono o agregar un registro.
@app.route("/update/<string:id>", methods=['POST'])
def update(id):
    # Variables usadas
    resultMessage = ""
    resultType = "success"
    calleFlag = 0
    numeroFlag = 0
    coloniaFlag = 0

    # Recibir los datos del formulario
    calle = request.form['calleUpdate']
    numero = request.form['numeroUpdate']
    colonia = request.form['coloniaUpdate']
    tel = request.form['telUpdate']

    updateAddressQuery = "UPDATE addresses SET "
    updateAddressData = []

    if calle:
        updateAddressQuery += "calle = %s "
        calleFlag = 1
        updateAddressData.append(calle)

    if numero:
        if calleFlag == 1:
            updateAddressQuery += ", numero = %s "
        else:
            updateAddressQuery += "numero = %s "
        numeroFlag = 1
        updateAddressData.append(numero)

    if colonia:
        if calleFlag == 1 or numeroFlag == 1:
            updateAddressQuery += ", colonia = %s "
        else:
            updateAddressQuery += "colonia = %s "
        coloniaFlag = 1
        updateAddressData.append(colonia)

    updateAddressQuery += "WHERE person_id = " + id

    if calleFlag == 1 or numeroFlag == 1 or coloniaFlag == 1:
        try:
            cursor = con.database.cursor()
            cursor.execute(updateAddressQuery, updateAddressData)
            con.database.commit()

            resultMessage = "Datos editados con éxito"
            resultType = "success"

            cursor.close()
        except Error as err:
            resultMessage = "Ocurrió un error al editar los datos"
            resultType = "error"

    if tel:
        try:
            cursor = con.database.cursor()

            updateTelQuery = "call update_tel(%s, %s)"
            updateTelData = (id, tel)

            cursor.execute(updateTelQuery, updateTelData)
            con.database.commit()

            resultMessage = "Datos editados con éxito"
            resultType = "success"

            cursor.close()
        except Error as err:
            resultMessage = "Ocurrió un error al editar los datos"
            resultType = "error"

    return redirect(url_for("home", result = resultMessage, resultType = resultType))

# Iniciar la aplicación
if __name__ == "__main__":
    app.run(debug=True, port=4000)
