//+------------------------------------------------------------------+
//|                                               PartialClose.mq4   |
//|             Script for Partially Closing Open Positions          |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string TargetSymbol = "";         // Target symbol (empty = all symbols)
input bool CloseBuyOrders = true;       // Partially close Buy orders
input bool CloseSellOrders = true;      // Partially close Sell orders
input double ClosePercentage = 50;      // Percentage of the position to close (0-100)
input double CloseLotSize = 0;          // Specific lot size to close (0 = use percentage)

//+------------------------------------------------------------------+
//| Main Function                                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   if (ClosePercentage < 0 || ClosePercentage > 100) {
      Print("Invalid ClosePercentage. Must be between 0 and 100.");
      return;
   }

   int totalOrders = OrdersTotal();
   bool errorOccurred = false;

   for (int i = totalOrders - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         // Check symbol if specified
         if (TargetSymbol != "" && OrderSymbol() != TargetSymbol) continue;

         // Determine order type
         int orderType = OrderType();
         if ((orderType == OP_BUY && CloseBuyOrders) || (orderType == OP_SELL && CloseSellOrders)) {
            double currentLots = OrderLots();
            double lotsToClose;

            // Calculate the lots to close
            if (CloseLotSize > 0) {
               lotsToClose = MathMin(CloseLotSize, currentLots); // Ensure not exceeding current lot size
            } else {
               lotsToClose = currentLots * (ClosePercentage / 100.0); // Percentage-based closure
               lotsToClose = NormalizeDouble(lotsToClose, 2); // Normalize to two decimal places
            }

            // Attempt to partially close the position
            double closePrice = (orderType == OP_BUY) ? Bid : Ask;
            bool result = OrderClose(OrderTicket(), lotsToClose, closePrice, 3, clrYellow);

            if (!result) {
               Print("Error partially closing order (Ticket: ", OrderTicket(), "): ", GetLastError());
               errorOccurred = true;
            } else {
               Print("Successfully partially closed order (Ticket: ", OrderTicket(), "). Closed lots: ", lotsToClose);
            }
         }
      } else {
         Print("Error selecting order: ", GetLastError());
         errorOccurred = true;
      }
   }

   if (!errorOccurred) {
      Print("Partial closure completed successfully.");
   } else {
      Print("Some positions could not be partially closed. Check the log for details.");
   }
}
