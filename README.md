# Partial Close Positions — MQL4 Script

A MetaTrader 4 script that performs **programmatic partial closure** of open market orders using a reverse-index `OrdersTotal()` loop, supporting both percentage-based and fixed lot-size reduction modes with optional symbol filtering, order-type filtering, and normalized lot size precision via `NormalizeDouble()`.

---

## Overview

Partial position closure is a fundamental risk management technique — reducing exposure after a target is hit while leaving a portion running. MT4's native interface doesn't provide a one-click partial close across multiple positions, making this script an essential utility for traders managing multiple concurrent orders. The script iterates all open positions in reverse index order to prevent selection errors during closure, calculates the exact lots to close using either a percentage or fixed lot mode, and calls `OrderClose()` with the current market price against the appropriate Bid or Ask. All results — successes and errors with their `GetLastError()` codes — are printed to the Experts log for full post-execution audit.

---

## Features

- **Dual closure modes:** percentage-based (`ClosePercentage`) or fixed lot size (`CloseLotSize > 0`) — fixed lot mode takes priority with `MathMin()` cap to prevent over-closure
- **Reverse-index iteration** — loops from `OrdersTotal() − 1` to `0` via `OrderSelect(i, SELECT_BY_POS, MODE_TRADES)` to prevent index shifting during active removal
- **Symbol filter** — optional `TargetSymbol` restricts closure to a specific instrument; empty string applies to all symbols
- **Order-type filter** — independent `CloseBuyOrders` and `CloseSellOrders` boolean flags allow directional-only closure
- **Normalized lot precision** — `NormalizeDouble(lotsToClose, 2)` ensures percentage-calculated lots conform to broker minimum lot step requirements
- **Correct market price selection** — Bid price for `OP_BUY` closures, Ask for `OP_SELL`, preventing requote errors on directional mismatch
- **Error tracking** — `errorOccurred` flag accumulates failures; per-order `GetLastError()` codes are printed individually for targeted debugging

---

## How It Works

1. `ClosePercentage` is validated to be within `0–100`; execution aborts with a log message if invalid
2. A reverse loop iterates all open orders via `OrderSelect(i, SELECT_BY_POS, MODE_TRADES)`
3. Symbol filter (`TargetSymbol`) and order type filter (`CloseBuyOrders` / `CloseSellOrders`) are applied as sequential gates
4. Closure lot size is resolved:
   - `CloseLotSize > 0` → `lotsToClose = MathMin(CloseLotSize, currentLots)` (fixed mode)
   - `CloseLotSize == 0` → `lotsToClose = NormalizeDouble(currentLots × (ClosePercentage / 100.0), 2)` (percentage mode)
5. `OrderClose(ticket, lotsToClose, closePrice, 3, clrYellow)` executes the partial closure with 3-point slippage tolerance
6. Success and failure counts are aggregated and summarized on completion

---

## Input Parameters

| Parameter         | Type   | Default | Description                                                              |
|-------------------|--------|---------|--------------------------------------------------------------------------|
| `TargetSymbol`    | string | `""`    | Symbol to target (empty = all open symbols)                              |
| `CloseBuyOrders`  | bool   | `true`  | Apply partial closure to `OP_BUY` orders                                 |
| `CloseSellOrders` | bool   | `true`  | Apply partial closure to `OP_SELL` orders                                |
| `ClosePercentage` | double | `50`    | Percentage of each position's current lot size to close (0–100)          |
| `CloseLotSize`    | double | `0`     | Fixed lot size to close per order (0 = use percentage mode instead)      |

---

## Installation

1. Copy `Close_All_Positions_001.mq4` to `MQL4/Scripts/` in your MT4 data folder
2. Compile in MetaEditor (F7)
3. Drag onto any chart from Navigator → Scripts
4. Configure inputs and click **OK**

> **Warning:** This script closes real orders on a live account immediately on execution. Always test on a **demo account** first and verify your input parameters before running on live capital.

> **Note:** Broker minimum lot size requirements apply. If `lotsToClose` falls below the broker's minimum after normalization, `OrderClose()` will fail with error 131. Adjust `ClosePercentage` or `CloseLotSize` accordingly.

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)
- Open positions on the account

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
