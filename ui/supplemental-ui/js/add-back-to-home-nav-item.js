(function () {
  const compHomeItem = document.querySelector('nav.nav-menu h3')
  const rootHomeItem = compHomeItem.cloneNode(true)
  rootHomeItem.firstChild.textContent = "⬆ Startpagina"
  rootHomeItem.firstChild.href = "/"
  compHomeItem.before(rootHomeItem)
  rootHomeItem.after(document.createElement("hr"))
})()
