import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="subscribe"
export default class extends Controller {
  static values = {swPath: String, userId: String, path: String, key: String};
  connect() {
    if (!navigator.serviceWorker || !window.PushManager) {
      this.updateButtonProps({
        text: "Push API not supported",
        disabled: true,
      });
      return;
    }

    switch (Notification.permission) {
      case "denied":
        this.updateButtonProps({
          text: "Notification permission denied",
          disabled: true,
        });
        return;
    }

    navigator.serviceWorker
      .getRegistration(this.swPathValue)
      .then((registration) => {
        if (!registration) {
          this.updateButtonProps({
            text: "Service Worker not registered",
            disabled: true,
          });
          throw "Service Worker not registered";
        }
        return registration;
      })
      .then((registration) => registration.pushManager.getSubscription())
      .then((subscription) => {
        if (!subscription) {
          this.updateButtonProps({ text: "Subscribe", action: "subscribe" });
          return;
        }

        this.updateButtonProps({ text: "Unsubscribe", action: "unsubscribe" });
      });
  }

  subscribe(event) {
    event.stopPropagation();
    event.preventDefault();

    // extract key and path from this element's attributes
    const key = new Uint8Array(
      atob(this.keyValue)
        .split("")
        .map((char) => char.charCodeAt(0)),
    );
    const path = this.pathValue;

    // request permission, perform subscribe, and post to server
    Notification.requestPermission().then((permission) => {
      if (permission !== "granted") return;

      navigator.serviceWorker
        .getRegistration(this.swPathValue)
        .then((registration) => {
          if (!registration) {
            throw "Service Worker not registered";
          }
          return registration;
        })
        .then((registration) =>
          registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: key,
          }),
        )
        .then((subscription) => subscription.toJSON())
        .then((subscription) => {
          if (!subscription.endpoint || !subscription.keys || !path) {
            throw "Invalid subscription";
          }

          return fetch(path, {
            method: "POST",
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.getAttribute("content") ?? "",
            },
            body: new URLSearchParams([
              ["subscription[endpoint]", subscription.endpoint],
              ["subscription[auth_key]", subscription.keys.auth],
              ["subscription[p256dh_key]", subscription.keys.p256dh],
              ["subscription[user_id]", this.userIdValue],
            ]),
          }).then(() => {
            this.updateButtonProps({
              text: "Unsubscribe",
              action: "unsubscribe",
            });
          });
        })
        .catch((error) => {
          console.error(`Web Push subscription failed: ${error}`);
        });
    });
  }

  unsubscribe(event) {
    event.stopPropagation();
    event.preventDefault();

    navigator.serviceWorker
      .getRegistration(this.swPathValue)
      .then((registration) => {
        if (!registration) {
          throw "Service Worker not registered";
        }
        return registration;
      })
      .then((registration) => registration.pushManager.getSubscription())
      .then((subscription) => {
        if (!subscription) return;

        return subscription.unsubscribe().then(() => {
          return fetch(this.pathValue, {
            method: "DELETE",
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.getAttribute("content") || "",
            },
            body: new URLSearchParams([
              ["subscription[endpoint]", subscription.endpoint],
              ["subscription[user_id]", this.userIdValue],
            ]),
          }).then(() => {
            this.updateButtonProps({ text: "Subscribe", action: "subscribe" });
          });
        });
      })
      .catch((error) => {
        console.error(`Web Push unsubscription failed: ${error}`);
      });
  }

  updateButtonProps(text, action, disabled, element = this.element) {
    if (disabled) {
      element.disabled = true;
    }
    if (text) element.innerText = text.text;
    if (action) element.dataset.action = `subscribe#${action}`;
  }
}
