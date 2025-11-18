

# 🧊 Lissandr

**Lissandr** is an iOS application that helps you track and monitor game discounts using the [CheapShark API](https://apidocs.cheapshark.com).  
Built with **Swift**, **UIKit**, **SnapKit**, and the **VIPER architecture**, it provides a clean, modular, and scalable codebase.

---

## ✨ Features

- 🏠 **Home Screen** — Browse the latest game deals on the main screen.
- 🔍 **Apple Music-Style Search** — Tap the search button to reveal an elegant search interface.
- 📊 **Detailed Game View** — Tap any game to see comprehensive price information across multiple stores.
- 🧾 **Track Games** — Add games to your Watchlist to monitor price drops.
- 💰 **Push Notifications** — Get notified when a tracked game goes on sale.
- 📱 **Modern UI** — Built with SnapKit and UIKit, featuring native iOS design patterns.
- 🔁 **Persistent Storage** — Your watchlist is saved locally using `UserDefaults`.
- ⚙️ **Async/Await Networking** — Uses a generic, reusable network layer.

---

## 🏗 Architecture

The app follows the **VIPER pattern**:

- **V**iew — Handles UI and user interaction (`DealsListViewController`, `SearchViewController`, `WatchlistViewController`, `GameDetailViewController`).
- **I**nteractor — Business logic and API calls (`DealsListInteractor`, `SearchInteractor`, `WatchlistInteractor`, `GameDetailInteractor`).
- **P**resenter — Coordinates between view and interactor.
- **E**ntity — Data models (`DealSummary`, `GameDetailResponse`, `WatchItem`, etc.).
- **R**outer — Manages navigation and module assembly.

---

## 🧱 Tech Stack

- **Swift 5.10+**
- **UIKit** + **SnapKit**
- **Kingfisher** (image caching)
- **CheapShark API**
- **VIPER architecture**
- **Background fetch + local notifications**

---

## 🧩 API

Lissandr integrates with the [CheapShark API](https://apidocs.cheapshark.com).  
Example endpoint usage:

```swift
GET https://www.cheapshark.com/api/1.0/deals
GET https://www.cheapshark.com/api/1.0/games?title={name}
GET https://www.cheapshark.com/api/1.0/deal?id={dealID}
```

---

## 🧊 Inspiration

Inspired by **Lissandra** from *League of Legends* — elegant, cold, and precise ❄️ 
Many thanks to Wtcn :) 
