# Grid Assistant Pro V22 🤖📈

**Grid Assistant Pro V22** is an advanced Expert Advisor (EA) for MetaTrader 5, specifically designed as a semi-automated grid trading assistant for the **XAUUSD (Gold)** pair.

This EA does not take random positions on its own. Instead, it gives you full control (acting as a sniper or director) by providing instant execution tools, mass SL/TP synchronization, and a highly advanced position rescue system (Smart Runner).

---

## 🔥 Key Features

### 1. ⚡ One-Click Grid Execution
Features an on-chart button panel (B & S). With a single click, the EA will execute 1 Market position and instantly deploy 8 Limit Order layers with dynamic distance (step) and lot multipliers based on your settings.

### 2. 🎯 Limit Order Catching
You can analyze the chart and place a single standard Buy Limit or Sell Limit at a key support/resistance area. Once touched (or even before it's touched), the EA will "catch" this limit order and instantly convert it into a full 8-layer grid array.

### 3. 🔄 Global SL/TP Sync
Forget modifying SL/TP one by one! Simply drag & drop the SL/TP line on ONE of your positions on the MT5 chart. The EA will detect it in milliseconds and **synchronize the SL/TP** across all active positions in the same group.

### 4. 🛡️ Independent Magic Grids & Manual Freedom
Every Grid you generate has its own unique Magic Number. This means Grid A and Grid B will never interfere with each other's SL/TP. Furthermore, **pure manual positions (Magic 0) are 100% ignored by the EA**, allowing you to safely manual scalp alongside the EA without getting tangled in its logic.

### 5. 🏃 Smart Auto-Runner (Survival TP)
The most genius feature of this EA. When you set a shared TP for a grid group, the EA secretly **removes the TP from your deepest (best-priced) position**.
* **The Result:** When the price hits your TP, all other positions take profit normally, while your best position **survives**. The EA then instantly cuts its lot size down to **0.01 lot** and lets it run free as a "Runner" to catch massive trends!

### 6. 🆘 Manual Close to Runner (Emergency Button)
Is your grid floating in minus due to unexpected fundamental news? Simply manually close ONE of its positions from your phone or terminal. The EA will trigger an emergency protocol: it closes all remaining floating trades, deletes all pending limit traps, and **rescues the best (deepest) position**, cutting its lot to 0.01 to serve as a Runner to recover your losses.

### 7. 🎛️ Interactive Utility Panel
* **B (Buy):** Instant Buy Grid execution.
* **S (Sell):** Instant Sell Grid execution.
* **C (Close):** Closes all open positions instantly.
* **X (Delete):** Deletes all pending Limit Orders.
* **CL (Clear SL/TP):** Safely wipes all synchronization memory and resets SL/TP to 0.0 for all positions.

---

## ⚙️ Installation Guide
1. Download the `GridEA_FixTP.mq5` file.
2. Place the file inside the `MQL5/Experts/` folder in your MetaTrader 5 data directory.
3. Compile it using MetaEditor (press F7).
4. Attach it to an XAUUSD chart. Make sure *Algo Trading* is enabled in your MT5 terminal.

> **Note:** This is a very powerful EA. Always use proper Money Management and adjust the `GridStep` and `Lot` multipliers in the Input settings according to your account equity.
