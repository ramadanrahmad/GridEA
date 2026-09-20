//+------------------------------------------------------------------+
//|                                              Asisten_Grid_Pro_V18|
//| Ultimate XAUUSD: Smart Hit & Run (Auto Delete Limit + BE Runner) |
//+------------------------------------------------------------------+
#property copyright "Hak Cipta Anda"
#property link      ""
#property version   "18.18" // Panic Button: Cache Sync History Fix

#include <Trade\Trade.mqh>
CTrade trade;

// --- SETTING KHUSUS SKALA XAUUSD (EMAS) ---
input double InpGridStep1    = 0.4;    // Jarak Layer Lot 1
input int    InpLimitLayer1  = 5;      // Jumlah layer lot pertama
input double InpLot1         = 0.01;   // Lot pertama

input double InpGridStep2    = 0.6;    // Jarak Layer Lot 2
input int    InpLimitLayer2  = 6;      // Jumlah layer lot kedua
input double InpLot2         = 0.02;   // Lot kedua

input double InpGridStep3    = 0.8;    // Jarak Layer Lot 3
input int    InpLimitLayer3  = 7;      // Jumlah layer lot ketiga
input double InpLot3         = 0.03;   // Lot ketiga

input double InpGridStep4    = 1.0;    // Jarak Layer Lot 4
input int    InpLimitLayer4  = 1;      // Jumlah layer lot keempat
input double InpLot4         = 0.04;   // Lot keempat

// --- SETTING SCALING OUT (TP BERJENJANG) ---
input double InpTP1_Pips     = 5.0;    // Jarak TP1 (50 Pips) -> Tutup 50% Layer + BE
input double InpTP2_Pips     = 10.0;   // Jarak TP2 (100 Pips) -> Tutup 40% Layer
input double InpTP3_Pips     = 15.0;   // Jarak TP3 (150 Pips) -> Tutup Sisa, Kecuali 1 Runner
input double InpRunnerAutoBE = 0.3;    // Jarak BE (+3 Pips / 0.3 Poin)
input double InpRunnerTargetLot = 0.01;// Target Sisa Lot Runner Saat TP Hit (Partial Close)

input double InpTargetTP     = 3.0;    // Target TP Awal Limit Order Belum Tersentuh (30 Pips)

// --- SETTING AUTO SHIFT TP (AVERAGING ESCAPE) ---
input double InpAutoShiftTPDistance = 10.0; // TRIGGER ESCAPE 1: Drawdown Jauh (100 Pips)
input double InpEscape2Distance     = 15.0; // TRIGGER ESCAPE 2: Drawdown Ekstrem (150 Pips)
input double InpEscape2Shift        = 5.0;  // GESER TP ESCAPE 2: Jarak TP dari Entry (50 Pips)

// --- VARIABEL GLOBAL ---
ulong last_processed_ticket = 0; 

//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectCreate(0, "BtnBuyGrid", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnBuyGrid", OBJPROP_TEXT, "B");
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_BGCOLOR, clrDodgerBlue);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_COLOR, clrWhite);
   
   ObjectCreate(0, "BtnSellGrid", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_XDISTANCE, 70); 
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnSellGrid", OBJPROP_TEXT, "S");
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_BGCOLOR, clrCrimson);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_COLOR, clrWhite);

   ObjectCreate(0, "BtnClosePos", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnClosePos", OBJPROP_TEXT, "C");
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_BGCOLOR, clrGoldenrod);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_COLOR, clrWhite);

   ObjectCreate(0, "BtnDelLimit", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_XDISTANCE, 170);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnDelLimit", OBJPROP_TEXT, "X");
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_BGCOLOR, clrDimGray);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_COLOR, clrWhite);

   Print("Asisten Grid V18.18 (Panic Button: Cache Sync History Fix) Siap Tempur!");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   ObjectDelete(0, "BtnBuyGrid");
   ObjectDelete(0, "BtnSellGrid");
   ObjectDelete(0, "BtnClosePos");
   ObjectDelete(0, "BtnDelLimit");
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == "BtnBuyGrid") { ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_BUY); }
      else if(sparam == "BtnSellGrid") { ObjectSetInteger(0, "BtnSellGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_SELL); }
      else if(sparam == "BtnClosePos") { ObjectSetInteger(0, "BtnClosePos", OBJPROP_STATE, false); ExecuteClosePos(); }
      else if(sparam == "BtnDelLimit") { ObjectSetInteger(0, "BtnDelLimit", OBJPROP_STATE, false); ExecuteDelLimit(); }
     }
  }

ulong GetRunnerTicket(long magic, long type)
  {
   ulong best_ticket = 0;
   double best_price = (type == POSITION_TYPE_BUY) ? 99999999.0 : 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            double op = PositionGetDouble(POSITION_PRICE_OPEN);
            if(type == POSITION_TYPE_BUY && op < best_price) { best_price = op; best_ticket = ticket; }
            else if(type == POSITION_TYPE_SELL && op > best_price) { best_price = op; best_ticket = ticket; }
           }
        }
     }
   return best_ticket;
  }

void ExecutePanicSweep(long magic, long type)
  {
   ulong runner_ticket = GetRunnerTicket(magic, type);
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            if(ticket != runner_ticket)
              {
               trade.PositionClose(ticket);
              }
           }
        }
     }
     
   ExecuteDelLimitByMagic(magic);
   
   string gv_panic = "GridV18_" + IntegerToString(magic) + "_" + IntegerToString(type) + "_Panic";
   GlobalVariableSet(gv_panic, 1);
  }

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result)
  {
   // PERBAIKAN MUTLAK: Paksa MT5 lokal untuk menyinkronkan data riwayat dengan broker secara instan
   HistorySelect(0, TimeCurrent() + 86400);

   if(trans.type == TRADE_TRANSACTION_HISTORY_ADD)
     {
      ulong ticket = trans.order;
      if(ticket > 0 && HistoryOrderSelect(ticket))
        {
         long magic = HistoryOrderGetInteger(ticket, ORDER_MAGIC);
         long state = HistoryOrderGetInteger(ticket, ORDER_STATE);
         long type  = HistoryOrderGetInteger(ticket, ORDER_TYPE);
         
         if(magic != 0 && state == ORDER_STATE_CANCELED)
           {
            if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT)
              {
               bool sisa_limit = false;
               for(int i = 0; i < OrdersTotal(); i++)
                 {
                  ulong t = OrderGetTicket(i);
                  if(OrderSelect(t) && OrderGetInteger(ORDER_MAGIC) == magic) { sisa_limit = true; break; }
                 }
               if(sisa_limit) ExecuteDelLimitByMagic(magic);
              }
           }
        }
     }
     
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong deal_ticket = trans.deal;
      if(deal_ticket > 0 && HistoryDealSelect(deal_ticket))
        {
         long entry  = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
         long reason = HistoryDealGetInteger(deal_ticket, DEAL_REASON);
         long magic  = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
         
         if(entry == DEAL_ENTRY_OUT && magic != 0 && reason != DEAL_REASON_EXPERT && reason != DEAL_REASON_TP && reason != DEAL_REASON_SL)
           {
            long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE); 
            long pos_type = (deal_type == DEAL_TYPE_SELL) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
            
            ExecutePanicSweep(magic, pos_type);
           }
        }
     }
  }

bool IsRunner(ulong my_ticket)
  {
   if(!PositionSelectByTicket(my_ticket)) return false;
   long my_magic = PositionGetInteger(POSITION_MAGIC);
   long my_type = PositionGetInteger(POSITION_TYPE);
   double my_price = PositionGetDouble(POSITION_PRICE_OPEN);

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == my_magic && PositionGetInteger(POSITION_TYPE) == my_type)
           {
            double other_price = PositionGetDouble(POSITION_PRICE_OPEN);
            ulong other_ticket = PositionGetTicket(i);
            if(other_ticket != my_ticket)
              {
               if(my_type == POSITION_TYPE_BUY && other_price < my_price) return false;
               if(my_type == POSITION_TYPE_SELL && other_price > my_price) return false;
              }
           }
        }
     }
   return true; 
  }

int CountGroup(long my_magic, long my_type)
  {
   int c = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == my_magic && PositionGetInteger(POSITION_TYPE) == my_type) c++;
        }
     }
   return c;
  }

void ExecutePartialClose(long magic, long type, int count_to_close)
  {
   if(count_to_close <= 0) return;
   
   int active_count = CountGroup(magic, type);
   if(active_count <= 1) return; 
   if(count_to_close >= active_count) count_to_close = active_count - 1; 
   
   ulong tickets[];
   double prices[];
   int idx = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong t = PositionGetTicket(i);
      if(PositionSelectByTicket(t) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            ArrayResize(tickets, idx + 1);
            ArrayResize(prices, idx + 1);
            tickets[idx] = t;
            prices[idx] = PositionGetDouble(POSITION_PRICE_OPEN);
            idx++;
           }
        }
     }
   
   for(int i = 0; i < idx - 1; i++)
     {
      for(int j = 0; j < idx - i - 1; j++)
        {
         bool swap = false;
         if(type == POSITION_TYPE_BUY && prices[j] < prices[j+1]) swap = true; 
         else if(type == POSITION_TYPE_SELL && prices[j] > prices[j+1]) swap = true; 
         
         if(swap)
           {
            double temp_p = prices[j]; prices[j] = prices[j+1]; prices[j+1] = temp_p;
            ulong temp_t = tickets[j]; tickets[j] = tickets[j+1]; tickets[j+1] = temp_t;
           }
        }
     }
     
   int closed = 0;
   for(int i = 0; i < idx && closed < count_to_close; i++)
     {
      trade.PositionClose(tickets[i]);
      closed++;
     }
  }

void ExecuteClosePos() { }
void ExecuteDelLimit()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol) trade.OrderDelete(ticket);
     }
  }

void ExecuteDelLimitByMagic(long target_magic)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == target_magic) trade.OrderDelete(ticket);
     }
  }

double GetLotForLayer(int layer_index)
  {
   if (layer_index <= InpLimitLayer1) return InpLot1;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2) return InpLot2;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3) return InpLot3;
   else return InpLot4;
  }

double GetDistanceForLayer(int layer_index)
  {
   double total_distance = 0.0;
   for(int i = 1; i <= layer_index; i++)
     {
      if (i <= InpLimitLayer1) total_distance += InpGridStep1;
      else if (i <= InpLimitLayer1 + InpLimitLayer2) total_distance += InpGridStep2;
      else if (i <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3) total_distance += InpGridStep3;
      else total_distance += InpGridStep4;
     }
   return total_distance;
  }

void ExecuteGridFromPrice(int limit_type, double base_price, double manual_tp)
  {
   int total_layers = InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4; 
   ulong current_magic = (ulong)GetTickCount64(); 
   trade.SetExpertMagicNumber(current_magic);
   
   if(limit_type == ORDER_TYPE_BUY_LIMIT)
     {
      double max_distance = GetDistanceForLayer(total_layers);
      double sl_price = NormalizeDouble(base_price - max_distance - InpGridStep4, _Digits);
      double target_tp = 0.0;
      if (manual_tp > 0) target_tp = manual_tp;
      else if (InpTargetTP > 0) target_tp = NormalizeDouble(base_price + InpTargetTP, _Digits);
      
      for(int i = 0; i <= total_layers; i++)
        {
         double lot = (i == 0) ? InpLot1 : GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(base_price - current_distance, _Digits);
         trade.BuyLimit(lot, limit_price, _Symbol, sl_price, target_tp, ORDER_TIME_GTC, 0, "Grid XAU Catch");
        }
     }
   else if(limit_type == ORDER_TYPE_SELL_LIMIT)
     {
      double max_distance = GetDistanceForLayer(total_layers);
      double sl_price = NormalizeDouble(base_price + max_distance + InpGridStep4, _Digits);
      double target_tp = 0.0;
      if (manual_tp > 0) target_tp = manual_tp;
      else if (InpTargetTP > 0) target_tp = NormalizeDouble(base_price - InpTargetTP, _Digits);
      
      for(int i = 0; i <= total_layers; i++)
        {
         double lot = (i == 0) ? InpLot1 : GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(base_price + current_distance, _Digits);
         trade.SellLimit(lot, limit_price, _Symbol, sl_price, target_tp, ORDER_TIME_GTC, 0, "Grid XAU Catch");
        }
     }
  }

void ExecuteGrid(int direction)
  {
   int total_layers = InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4; 
   ulong current_magic = (ulong)GetTickCount64(); 
   trade.SetExpertMagicNumber(current_magic);
   
   if(direction == ORDER_TYPE_BUY)
     {
      double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double max_distance = GetDistanceForLayer(total_layers);
      double last_limit_price = Ask - max_distance;
      double sl_price = NormalizeDouble(last_limit_price - InpGridStep4, _Digits);
      double target_tp = (InpTargetTP > 0) ? NormalizeDouble(Ask + InpTargetTP, _Digits) : 0.0; 
      
      trade.Buy(InpLot1, _Symbol, Ask, sl_price, target_tp, "Grid XAU BUY");
      for(int i = 1; i <= total_layers; i++)
        {
         double lot = GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(Ask - current_distance, _Digits);
         trade.BuyLimit(lot, limit_price, _Symbol, sl_price, target_tp, ORDER_TIME_GTC, 0, "Grid XAU Buy Limit");
        }
     }
   else if(direction == ORDER_TYPE_SELL)
     {
      double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double max_distance = GetDistanceForLayer(total_layers);
      double last_limit_price = Bid + max_distance;
      double sl_price = NormalizeDouble(last_limit_price + InpGridStep4, _Digits);
      double target_tp = (InpTargetTP > 0) ? NormalizeDouble(Bid - InpTargetTP, _Digits) : 0.0; 
      
      trade.Sell(InpLot1, _Symbol, Bid, sl_price, target_tp, "Grid XAU SELL");
      for(int i = 1; i <= total_layers; i++)
        {
         double lot = GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(Bid + current_distance, _Digits);
         trade.SellLimit(lot, limit_price, _Symbol, sl_price, target_tp, ORDER_TIME_GTC, 0, "Grid XAU Sell Limit");
        }
     }
  }

void CleanupMemory()
  {
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
     {
      string name = GlobalVariableName(i);
      if(StringFind(name, "GridV18_") == 0)
        {
         string parts[];
         StringSplit(name, '_', parts);
         if(ArraySize(parts) >= 4)
           {
            long m = StringToInteger(parts[1]);
            long t = StringToInteger(parts[2]);
            if(CountGroup(m, t) == 0) 
              {
               GlobalVariableDel(name);       
               ExecuteDelLimitByMagic(m);     
              }
           }
        }
     }
  }

void ProcessGroupState(long magic, long type)
  {
   int current_count = CountGroup(magic, type);
   if(current_count == 0) return;
   
   double first_price = (type == POSITION_TYPE_BUY) ? 0.0 : 99999999.0;
   double worst_price = (type == POSITION_TYPE_BUY) ? 99999999.0 : 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            double open = PositionGetDouble(POSITION_PRICE_OPEN);
            if(type == POSITION_TYPE_BUY) { 
               if(open > first_price) first_price = open;
               if(open < worst_price) worst_price = open;
            } else { 
               if(open < first_price) first_price = open;
               if(open > worst_price) worst_price = open;
            }
           }
        }
     }
     
   double distance = (type == POSITION_TYPE_BUY) ? (first_price - worst_price) : (worst_price - first_price);
   if(distance >= InpAutoShiftTPDistance) return; // Escape ambil alih, hentikan Virtual TP 1/2

   string gv_total = "GridV18_" + IntegerToString(magic) + "_" + IntegerToString(type) + "_Total";
   string gv_tp1   = "GridV18_" + IntegerToString(magic) + "_" + IntegerToString(type) + "_TP1";
   string gv_tp2   = "GridV18_" + IntegerToString(magic) + "_" + IntegerToString(type) + "_TP2";
   
   double max_total = current_count;
   if(GlobalVariableCheck(gv_total)) max_total = MathMax(GlobalVariableGet(gv_total), current_count);
   
   double tp1_status = GlobalVariableCheck(gv_tp1) ? GlobalVariableGet(gv_tp1) : 0;
   double tp2_status = GlobalVariableCheck(gv_tp2) ? GlobalVariableGet(gv_tp2) : 0;
   
   if(tp1_status == 0) GlobalVariableSet(gv_total, max_total);
   
   double current_price = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   if(tp1_status == 0)
     {
      bool hit_tp1 = false;
      if(type == POSITION_TYPE_BUY && current_price >= first_price + InpTP1_Pips) hit_tp1 = true;
      if(type == POSITION_TYPE_SELL && current_price <= first_price - InpTP1_Pips) hit_tp1 = true;
      
      if(hit_tp1)
        {
         int to_close = (int)MathCeil(max_total * 0.5); 
         ExecutePartialClose(magic, type, to_close); 
         ExecuteDelLimitByMagic(magic); 
         GlobalVariableSet(gv_tp1, 1);
         tp1_status = 1;
        }
     }
     
   if(tp1_status == 1 && tp2_status == 0)
     {
      bool hit_tp2 = false;
      if(type == POSITION_TYPE_BUY && current_price >= first_price + InpTP2_Pips) hit_tp2 = true;
      if(type == POSITION_TYPE_SELL && current_price <= first_price - InpTP2_Pips) hit_tp2 = true;
      
      if(hit_tp2)
        {
         int to_close = (int)MathCeil(max_total * 0.4); 
         ExecutePartialClose(magic, type, to_close); 
         GlobalVariableSet(gv_tp2, 1);
        }
     }
  }

double GetGroupSL(long magic, long type)
  {
   double found_sl = (type == POSITION_TYPE_BUY) ? 0.0 : 99999999.0;
   bool sl_found = false;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            double sl = PositionGetDouble(POSITION_SL);
            if(type == POSITION_TYPE_BUY && sl > 0) { if(!sl_found || sl > found_sl) { found_sl = sl; sl_found = true; } }
            else if(type == POSITION_TYPE_SELL && sl > 0) { if(!sl_found || sl < found_sl) { found_sl = sl; sl_found = true; } }
           }
        }
     }
   if(sl_found) return found_sl;
   return ((type == POSITION_TYPE_BUY) ? 0.0 : 99999999.0);
  }

void OnTick()
  {
   if(ObjectGetInteger(0, "BtnBuyGrid", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_BUY); }
   if(ObjectGetInteger(0, "BtnSellGrid", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnSellGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_SELL); }
   if(ObjectGetInteger(0, "BtnClosePos", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnClosePos", OBJPROP_STATE, false); ExecuteClosePos(); }
   if(ObjectGetInteger(0, "BtnDelLimit", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnDelLimit", OBJPROP_STATE, false); ExecuteDelLimit(); }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         if(OrderGetInteger(ORDER_MAGIC) == 0) 
           {
            if(ticket == last_processed_ticket) continue; 
            long type = OrderGetInteger(ORDER_TYPE);
            if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT)
              {
               double manual_price = OrderGetDouble(ORDER_PRICE_OPEN);
               double manual_tp = OrderGetDouble(ORDER_TP); 
               if(trade.OrderDelete(ticket)) 
                 {
                  last_processed_ticket = ticket; 
                  ExecuteGridFromPrice((int)type, manual_price, manual_tp); 
                 }
              }
           }
        }
     }

   CleanupMemory();
   
   long processed_groups[100];
   int processed_count = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong t = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      long m = PositionGetInteger(POSITION_MAGIC);
      long type = PositionGetInteger(POSITION_TYPE);
      
      bool already = false;
      for(int j = 0; j < processed_count; j+=2) { if(processed_groups[j] == m && processed_groups[j+1] == type) { already = true; break; } }
      if(already) continue;
      
      processed_groups[processed_count] = m;
      processed_groups[processed_count+1] = type;
      processed_count += 2;
      
      ProcessGroupState(m, type);
     }

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket) || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      long my_magic = PositionGetInteger(POSITION_MAGIC);
      long my_type  = PositionGetInteger(POSITION_TYPE);
      double my_sl  = PositionGetDouble(POSITION_SL);
      double my_tp  = PositionGetDouble(POSITION_TP);
      double my_op  = PositionGetDouble(POSITION_PRICE_OPEN);
      
      string gv_tp1 = "GridV18_" + IntegerToString(my_magic) + "_" + IntegerToString(my_type) + "_TP1";
      bool tp1_hit = (GlobalVariableCheck(gv_tp1) && GlobalVariableGet(gv_tp1) == 1);
      
      string gv_panic = "GridV18_" + IntegerToString(my_magic) + "_" + IntegerToString(my_type) + "_Panic";
      bool panic_hit = (GlobalVariableCheck(gv_panic) && GlobalVariableGet(gv_panic) == 1);
      
      double first_price = (my_type == POSITION_TYPE_BUY) ? 0.0 : 99999999.0;
      double worst_price = (my_type == POSITION_TYPE_BUY) ? 99999999.0 : 0.0;
      
      for(int j = 0; j < PositionsTotal(); j++) {
         if(PositionSelectByTicket(PositionGetTicket(j)) && PositionGetInteger(POSITION_MAGIC) == my_magic && PositionGetInteger(POSITION_TYPE) == my_type) {
            double op = PositionGetDouble(POSITION_PRICE_OPEN);
            if(my_type == POSITION_TYPE_BUY) { if(op > first_price) first_price = op; if(op < worst_price) worst_price = op; }
            else { if(op < first_price) first_price = op; if(op > worst_price) worst_price = op; }
         }
      }
      
      double distance = (my_type == POSITION_TYPE_BUY) ? (first_price - worst_price) : (worst_price - first_price);
      
      bool escape_active = false;
      double escape_tp = 0.0;
      
      if(distance >= InpEscape2Distance) {
          escape_active = true;
          escape_tp = (my_type == POSITION_TYPE_BUY) ? NormalizeDouble(first_price - InpEscape2Shift, _Digits) : NormalizeDouble(first_price + InpEscape2Shift, _Digits);
      }
      else if(distance >= InpAutoShiftTPDistance) {
          escape_active = true;
          escape_tp = first_price;
      }
      
      string gv_escape = "GridV18_" + IntegerToString(my_magic) + "_" + IntegerToString(my_type) + "_Escape";
      bool escape_hit = (GlobalVariableCheck(gv_escape) && GlobalVariableGet(gv_escape) == 1);

      if(escape_active && !escape_hit)
        {
         double current_price = (my_type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(my_type == POSITION_TYPE_BUY && current_price >= escape_tp) { escape_hit = true; GlobalVariableSet(gv_escape, 1); }
         if(my_type == POSITION_TYPE_SELL && current_price <= escape_tp) { escape_hit = true; GlobalVariableSet(gv_escape, 1); }
        }

      bool final_tp_hit = escape_hit;
      if(!escape_active) {
          double normal_tp = (my_type == POSITION_TYPE_BUY) ? NormalizeDouble(first_price + InpTP3_Pips, _Digits) : NormalizeDouble(first_price - InpTP3_Pips, _Digits);
          double current_price = (my_type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          if(my_type == POSITION_TYPE_BUY && current_price >= normal_tp) final_tp_hit = true;
          if(my_type == POSITION_TYPE_SELL && current_price <= normal_tp) final_tp_hit = true;
      }

      double group_sl = GetGroupSL(my_magic, my_type);
      double target_sl = my_sl;
      double target_tp = my_tp;
      bool is_runner = IsRunner(ticket);
      bool modify = false;
      
      if(is_runner && final_tp_hit) {
          string gv_shrink = "GridV18_" + IntegerToString(my_magic) + "_" + IntegerToString(my_type) + "_Shrink";
          if(!GlobalVariableCheck(gv_shrink)) {
              double vol = PositionGetDouble(POSITION_VOLUME);
              if(vol > InpRunnerTargetLot) {
                  trade.PositionClosePartial(ticket, NormalizeDouble(vol - InpRunnerTargetLot, 2));
              }
              GlobalVariableSet(gv_shrink, 1); 
          }
      }

      if(escape_active || escape_hit || panic_hit)
        {
         if(is_runner) target_tp = 0.0; 
         else target_tp = escape_tp;
        }
      else
        {
         if(is_runner) target_tp = 0.0; 
         else target_tp = (my_type == POSITION_TYPE_BUY) ? NormalizeDouble(first_price + InpTP3_Pips, _Digits) : NormalizeDouble(first_price - InpTP3_Pips, _Digits);
        }
        
      if(tp1_hit || escape_hit || panic_hit) 
        {
         if(is_runner)
           {
            target_sl = (my_type == POSITION_TYPE_BUY) ? NormalizeDouble(my_op + InpRunnerAutoBE, _Digits) : NormalizeDouble(my_op - InpRunnerAutoBE, _Digits);
           }
         else
           {
            target_sl = (my_type == POSITION_TYPE_BUY) ? NormalizeDouble(worst_price + InpRunnerAutoBE, _Digits) : NormalizeDouble(worst_price - InpRunnerAutoBE, _Digits);
           }
        }
      else 
        {
         target_sl = group_sl;
        }
        
      if(MathAbs(target_sl - my_sl) > _Point * 0.5 || MathAbs(target_tp - my_tp) > _Point * 0.5) 
         trade.PositionModify(ticket, target_sl, target_tp);
     }
     
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(!OrderSelect(ticket) || OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      
      long my_magic = OrderGetInteger(ORDER_MAGIC);
      long o_type = OrderGetInteger(ORDER_TYPE);
      long my_type = (o_type == ORDER_TYPE_BUY_LIMIT || o_type == ORDER_TYPE_BUY_STOP) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
      double my_tp = OrderGetDouble(ORDER_TP);
      double my_sl = OrderGetDouble(ORDER_SL);
      double price_open = OrderGetDouble(ORDER_PRICE_OPEN);
      
      double group_sl = GetGroupSL(my_magic, my_type);
      double target_sl = my_sl;
      double target_tp = my_tp; 
      bool modify = false;

      if(group_sl > 0 && group_sl != 99999999.0 && MathAbs(my_sl - group_sl) > _Point * 0.5) {
         target_sl = group_sl; modify = true;
      }

      if(modify) {
         trade.OrderModify(ticket, price_open, target_sl, target_tp, ORDER_TIME_GTC, 0);
      }
     }
  }
//+------------------------------------------------------------------+