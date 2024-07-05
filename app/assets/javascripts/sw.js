self.addEventListener("push", event => {
  const { title, ...options } = event.data.json();
  self.registration.showNotification(title, options);
})
