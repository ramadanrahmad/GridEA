# Grid Assistant Pro V22.23 🤖📈

**Grid Assistant Pro V22.23** (`GridEA_Sync.mq5`) is an advanced Expert Advisor (EA) for MetaTrader 5, designed as a semi-automated grid trading assistant for **Gold (XAUUSD)** and **Forex pairs (EURUSD, GBPUSD, USDJPY, etc.)**.

This EA does not take random positions on its own. Instead, it gives you full control by providing instant execution tools, mass SL/TP synchronization, real-time visual BEP & dashboard monitoring, and a highly advanced position rescue & trend-catching system (Smart Runner with BE+ Protection).

---

## 🔥 Key Features

### 1. ⚡ One-Click Grid Execution
Features an on-chart utility panel (`B` & `S`). With a single click:
* Executes 1 Market order immediately.
* Instantly deploys 8 Limit Order layers with dynamic distance (pips) and lot multipliers based on your input settings.

### 2. 🎯 Limit Order Catching
Place a single standard Buy Limit or Sell Limit at any key support/resistance area. Once touched (or even before it's touched), the EA automatically catches it and deploys the remaining grid array according to your configuration.

### 3. 📊 Visual Dashboard & Live BEP Line
* **Live BEP Line:** Displays an automatic Break-Even Point (weighted average open price) line directly on your chart in real-time.
* **On-Chart Mini Dashboard:** Displays active layer count, total lot size, net volume (Buy vs Sell), floating profit/loss, and runner status.

### 4. 🔄 Global SL/TP Sync
Forget modifying SL/TP one by one! Simply drag and drop the SL/TP line on **any single position** in MT5. The EA detects the change in milliseconds and synchronizes the SL and TP across all active positions in the same grid group.

### 5. 🏃 Smart Auto-Runner (Survival TP & BE+ Lock)
* When a shared TP is reached, the EA takes profit on all standard positions while secretly keeping your deepest, best-priced position alive.
* The surviving position is trimmed down to **0.01 lot** and converted into a **Runner**.
* **BE+ Protection:** The runner's Stop Loss is immediately locked to Break-Even + profit (`InpRunnerBEPips`, default `0.3` pips), and protected against any global sync overwrites so it can ride long-term trends risk-free!

### 6. 🆘 Manual Close to Runner (Emergency Protocol)
If a grid is caught in unexpected high-impact news, you can manually close any single position from your desktop or MT5 mobile app. The EA will immediately trigger an emergency cleanup: closes all floating trades, deletes all pending limits, and rescues your best position into a protected 0.01 Runner.

### 7. 🛡️ Independent Magic Grids & Multi-Instrument Support
* **Multi-Instrument:** Automatically calculates proper pip dimensions for Gold (2-digit/3-digit) and Forex (4-digit/5-digit, JPY pairs).
* **Isolated Groups:** Every grid generated has a unique Magic Number. Multiple grids will never interfere with each other.
* **Manual Position Freedom:** Pure manual positions (`Magic = 0`) are completely ignored by the EA.

### 8. 🎛️ Interactive Utility Panel
* **B (Buy):** Instant Buy Grid execution.
* **S (Sell):** Instant Sell Grid execution.
* **C (Close):** Closes all open positions instantly.
* **X (Delete):** Deletes all pending Limit Orders.
* **CL (Clear SL/TP):** Safely wipes synchronization memory and resets SL/TP to 0.0.

---

## ⚙️ Installation Guide
1. Copy [GridEA_Sync.mq5](file:///d:/Project%20Website/EA%20Trading/GridEA_Sync.mq5) into your MetaTrader 5 `MQL5/Experts/` directory.
2. Open MetaEditor (press `F4` in MT5), open `GridEA_Sync.mq5`, and click **Compile** (`F7`).
3. Attach the EA to your desired chart (e.g., `XAUUSD` or `EURUSD`).
4. Ensure **Allow Algo Trading** is enabled in both MT5 Options and the EA settings dialog.

> **Note:** Always practice proper risk management and adjust `GridStep` and `Lot` parameters to match your account equity.
