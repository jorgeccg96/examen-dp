const resultadosCon = document.getElementById('resultados')

const resultados = document.getElementById('resultados');
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);

let result = urlParams.get("result");
let resultType = urlParams.get("resultType");
let resultId = urlParams.get("resultId");

if (result && resultType) {
    let msgElement = `<div class="section alert_con"><div class="content ${resultType}">${result}`;
    if (resultType == "borrado") msgElement += `<a class="btn btn-primary" href="/reactivate/${resultId}">Reactivar</a>`;
    msgElement += "</div></div>";
    document.body.innerHTML += msgElement;
}