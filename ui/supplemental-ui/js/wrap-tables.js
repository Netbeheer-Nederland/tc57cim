document.querySelectorAll("table.tableblock").forEach( function (table) {
    var container = Object.assign(document.createElement("div"), { className: "table-container" })
    table.parentNode.insertBefore(container, table).appendChild(table)
})
