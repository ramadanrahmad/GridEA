//+------------------------------------------------------------------+
//|                                              Asisten_Grid_Pro_V22|
//| Ultimate XAUUSD: Independent Magic Grids + Smart Auto-Runner     |
//+------------------------------------------------------------------+
#property copyright "Hak Cipta Anda"
#property link      ""
#property version   "22.00" 

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

input double InpGridStep5    = 1.2;    // Jarak Layer Lot 5
input int    InpLimitLayer5  = 1;      // Jumlah layer lot kelima
input double InpLot5         = 0.05;   // Lot kelima

input double InpGridStep6    = 1.4;    // Jarak Layer Lot 6
input int    InpLimitLayer6  = 1;      // Jumlah layer lot keenam
input double InpLot6         = 0.06;   // Lot keenam

input double InpGridStep7    = 1.6;    // Jarak Layer Lot 7
input int    InpLimitLayer7  = 1;      // Jumlah layer lot ketujuh
input double InpLot7         = 0.07;   // Lot ketujuh

input double InpGridStep8    = 1.8;    // Jarak Layer Lot 8
input int    InpLimitLayer8  = 1;      // Jumlah layer lot kedelapan
input double InpLot8         = 0.08;   // Lot kedelapan

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
   
   ObjectCreate(0, "BtnClearSLTP", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_XDISTANCE, 220);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnClearSLTP", OBJPROP_TEXT, "CL");
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_BGCOLOR, clrDarkViolet);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_COLOR, clrWhite);

   Print("Asisten Grid V22.00 (Independent Magic + Smart Runner) Siap Tempur!");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   ObjectDelete(0, "BtnBuyGrid");
   ObjectDelete(0, "BtnSellGrid");
   ObjectDelete(0, "BtnClosePos");
   ObjectDelete(0, "BtnDelLimit");
   ObjectDelete(0, "BtnClearSLTP");
  }

void ExecuteRunnerPhase(long magic, long type)
  {
   // Mencegah loop eksekusi ganda jika banyak posisi ditutup serentak
   string lock_name = "GridV22_RunnerLock_" + IntegerToString(magic);
   if(GlobalVariableCheck(lock_name)) return; 
   GlobalVariableSet(lock_name, 1.0); 
   
   // 1. Bersihkan limit orders
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic) trade.OrderDelete(ticket);
     }
     
   // 2. Cari posisi terbaik yang MASIH HIDUP di grup ini
   ulong best_ticket = 0;
   double best_price = (type == POSITION_TYPE_BUY) ? 999999.0 : 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
            if(type == POSITION_TYPE_BUY && open_price < best_price) { best_price = open_price; best_ticket = ticket; }
            if(type == POSITION_TYPE_SELL && open_price > best_price) { best_price = open_price; best_ticket = ticket; }
           }
        }
     }
     
   // 3. Tutup paksa semua posisi KECUALI yang terbaik
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            if(ticket != best_ticket) trade.PositionClose(ticket);
           }
        }
     }
     
   // 4. Jadikan posisi terbaik sebagai RUNNER
   if(best_ticket > 0 && PositionSelectByTicket(best_ticket))
     {
      double current_sl = PositionGetDouble(POSITION_SL);
      trade.PositionModify(best_ticket, current_sl, 0.0); // Hapus TP agar bebas lari
      
      double volume = PositionGetDouble(POSITION_VOLUME);
      if(volume > 0.01) trade.PositionClosePartial(best_ticket, volume - 0.01);
     }
     
   // 5. Hapus tracking SL/TP agar Auto-Sync tidak membebani Runner
   string gv_sl = "GridV22_" + IntegerToString(magic) + "_SL";
   string gv_tp = "GridV22_" + IntegerToString(magic) + "_TP";
   GlobalVariableDel(gv_sl);
   GlobalVariableDel(gv_tp);
  }

void CleanupMemory()
  {
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
     {
      string name = GlobalVariableName(i);
      if(StringFind(name, "GridV22_") == 0)
        {
         string parts[];
         StringSplit(name, '_', parts);
         long m = 0;
         
         if(ArraySize(parts) == 3 && (parts[2] == "SL" || parts[2] == "TP")) m = StringToInteger(parts[1]);
         if(ArraySize(parts) == 3 && parts[1] == "RunnerLock") m = StringToInteger(parts[2]); 
         
         if(m != 0)
           {
            bool found = false;
            for(int p = 0; p < PositionsTotal(); p++) {
                if(PositionSelectByTicket(PositionGetTicket(p)) && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == m) { found = true; break; }
            }
            if(!found) {
                for(int p = 0; p < OrdersTotal(); p++) {
                    if(OrderSelect(OrderGetTicket(p)) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == m) { found = true; break; }
                }
            }
            
            if(!found) GlobalVariableDel(name);
           }
        }
     }
  }

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result)
  {
   HistorySelect(0, TimeCurrent() + 86400);

   if(trans.type == TRADE_TRANSACTION_HISTORY_ADD)
     {
      ulong ticket = trans.order;
      if(ticket > 0 && HistoryOrderSelect(ticket))
        {
         long state = HistoryOrderGetInteger(ticket, ORDER_STATE);
         long type  = HistoryOrderGetInteger(ticket, ORDER_TYPE);
         long magic = HistoryOrderGetInteger(ticket, ORDER_MAGIC);
         
         if(state == ORDER_STATE_CANCELED && magic != 0)
           {
            if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT)
              {
               if(HistoryOrderGetString(ticket, ORDER_SYMBOL) == _Symbol)
                 {
                  long pos_type = (type == ORDER_TYPE_BUY_LIMIT) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
                  bool sisa_limit = false;
                  for(int i = 0; i < OrdersTotal(); i++)
                    {
                     ulong t = OrderGetTicket(i);
                     if(OrderSelect(t) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic)
                       {
                        long t_type = OrderGetInteger(ORDER_TYPE);
                        if((pos_type == POSITION_TYPE_BUY && t_type == ORDER_TYPE_BUY_LIMIT) ||
                           (pos_type == POSITION_TYPE_SELL && t_type == ORDER_TYPE_SELL_LIMIT))
                           { sisa_limit = true; break; }
                       }
                    }
                  if(sisa_limit) 
                    {
                     for(int i = OrdersTotal() - 1; i >= 0; i--)
                       {
                        ulong t = OrderGetTicket(i);
                        if(OrderSelect(t) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic)
                          {
                           long t_type = OrderGetInteger(ORDER_TYPE);
                           if((pos_type == POSITION_TYPE_BUY && t_type == ORDER_TYPE_BUY_LIMIT) ||
                              (pos_type == POSITION_TYPE_SELL && t_type == ORDER_TYPE_SELL_LIMIT)) trade.OrderDelete(t);
                          }
                       }
                    }
                 }
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
         
         if(entry == DEAL_ENTRY_OUT && (reason == DEAL_REASON_CLIENT || reason == DEAL_REASON_TP))
           {
            long order_ticket = HistoryDealGetInteger(deal_ticket, DEAL_ORDER);
            if(HistoryOrderSelect(order_ticket) && HistoryOrderGetString(order_ticket, ORDER_SYMBOL) == _Symbol)
              {
               long magic = HistoryOrderGetInteger(order_ticket, ORDER_MAGIC);
               if(magic != 0) // Abaikan posisi manual
                 {
                  long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE); 
                  long pos_type = (deal_type == DEAL_TYPE_SELL) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
                  ExecuteRunnerPhase(magic, pos_type);
                 }
              }
           }
        }
     }
  }

void ExecuteClosePos() 
  { 
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol) trade.PositionClose(ticket);
     }
  }

void ExecuteDelLimit()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol) trade.OrderDelete(ticket);
     }
  }
  
void ExecuteClearSLTP()
  {
   // Hapus semua pelacak GV
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
     {
      string name = GlobalVariableName(i);
      if(StringFind(name, "GridV21_") == 0 || StringFind(name, "GridV20_") == 0 || StringFind(name, "GridV22_") == 0) GlobalVariableDel(name);
     }
     
   // Hapus paksa SL/TP ke 0.0 di terminal
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         trade.PositionModify(ticket, 0.0, 0.0);
        }
     }
  }

double GetLotForLayer(int layer_index)
  {
   if (layer_index <= InpLimitLayer1) return InpLot1;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2) return InpLot2;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3) return InpLot3;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4) return InpLot4;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5) return InpLot5;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6) return InpLot6;
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6 + InpLimitLayer7) return InpLot7;
   else return InpLot8;
  }

double GetDistanceForLayer(int layer_index)
  {
   double total_distance = 0.0;
   for(int i = 1; i <= layer_index; i++)
     {
      if (i <= InpLimitLayer1) total_distance += InpGridStep1;
      else if (i <= InpLimitLayer1 + InpLimitLayer2) total_distance += InpGridStep2;
      else if (i <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3) total_distance += InpGridStep3;
      else if (i <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4) total_distance += InpGridStep4;
      else if (i <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5) total_distance += InpGridStep5;
      else if (i <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6) total_distance += InpGridStep6;
      else if (i <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6 + InpLimitLayer7) total_distance += InpGridStep7;
      else total_distance += InpGridStep8;
     }
   return total_distance;
  }

void ExecuteGridFromPrice(int limit_type, double base_price, double manual_tp)
  {
   int total_layers = InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6 + InpLimitLayer7 + InpLimitLayer8; 
   ulong current_magic = (ulong)GetTickCount64(); 
   trade.SetExpertMagicNumber(current_magic);
   
   if(limit_type == ORDER_TYPE_BUY_LIMIT)
     {
      for(int i = 0; i <= total_layers; i++)
        {
         double lot = (i == 0) ? InpLot1 : GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(base_price - current_distance, _Digits);
         trade.BuyLimit(lot, limit_price, _Symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, "Grid XAU Catch");
        }
     }
   else if(limit_type == ORDER_TYPE_SELL_LIMIT)
     {
      for(int i = 0; i <= total_layers; i++)
        {
         double lot = (i == 0) ? InpLot1 : GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(base_price + current_distance, _Digits);
         trade.SellLimit(lot, limit_price, _Symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, "Grid XAU Catch");
        }
     }
  }

void ExecuteGrid(int direction)
  {
   int total_layers = InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6 + InpLimitLayer7 + InpLimitLayer8; 
   ulong current_magic = (ulong)GetTickCount64(); 
   trade.SetExpertMagicNumber(current_magic);
   
   if(direction == ORDER_TYPE_BUY)
     {
      double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      trade.Buy(InpLot1, _Symbol, Ask, 0.0, 0.0, "Grid XAU BUY");
      for(int i = 1; i <= total_layers; i++)
        {
         double lot = GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(Ask - current_distance, _Digits);
         trade.BuyLimit(lot, limit_price, _Symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, "Grid XAU Buy Limit");
        }
     }
   else if(direction == ORDER_TYPE_SELL)
     {
      double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      trade.Sell(InpLot1, _Symbol, Bid, 0.0, 0.0, "Grid XAU SELL");
      for(int i = 1; i <= total_layers; i++)
        {
         double lot = GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(Bid + current_distance, _Digits);
         trade.SellLimit(lot, limit_price, _Symbol, 0.0, 0.0, ORDER_TIME_GTC, 0, "Grid XAU Sell Limit");
        }
     }
  }

void SyncGroupSLTP(long magic, long type)
  {
   if(magic == 0) return; // ABAIKAN ENTRI MANUAL (Magic 0)
   
   string gv_sl = "GridV22_" + IntegerToString(magic) + "_SL";
   string gv_tp = "GridV22_" + IntegerToString(magic) + "_TP";
   
   double last_known_sl = GlobalVariableCheck(gv_sl) ? GlobalVariableGet(gv_sl) : 0.0;
   double last_known_tp = GlobalVariableCheck(gv_tp) ? GlobalVariableGet(gv_tp) : 0.0;
   
   bool sl_changed = false;
   bool tp_changed = false;
   double new_sl = last_known_sl;
   double new_tp = last_known_tp;
   
   ulong best_ticket = 0;
   double best_price = (type == POSITION_TYPE_BUY) ? 999999.0 : 0.0;
   int group_positions = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            group_positions++;
            double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
            if(type == POSITION_TYPE_BUY && open_price < best_price) { best_price = open_price; best_ticket = ticket; }
            if(type == POSITION_TYPE_SELL && open_price > best_price) { best_price = open_price; best_ticket = ticket; }
            
            double pos_sl = PositionGetDouble(POSITION_SL);
            double pos_tp = PositionGetDouble(POSITION_TP);
            
            if(pos_sl > 0.0 && MathAbs(pos_sl - last_known_sl) > _Point * 0.5) { new_sl = pos_sl; sl_changed = true; }
            if(pos_tp > 0.0 && MathAbs(pos_tp - last_known_tp) > _Point * 0.5) { new_tp = pos_tp; tp_changed = true; }
           }
        }
     }
     
   if(sl_changed || tp_changed)
     {
      if(sl_changed) GlobalVariableSet(gv_sl, new_sl);
      if(tp_changed) GlobalVariableSet(gv_tp, new_tp);
     }
     
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic && PositionGetInteger(POSITION_TYPE) == type)
           {
            double current_sl = PositionGetDouble(POSITION_SL);
            double current_tp = PositionGetDouble(POSITION_TP);
            
            double target_sl = (new_sl > 0.0) ? new_sl : current_sl;
            double target_tp = (new_tp > 0.0) ? new_tp : current_tp;
            
            // PENGECUALIAN TP UNTUK SURVIVAL RUNNER: 
            // Jika ada lebih dari 1 posisi di grup, posisi terdalam (best_ticket) TIDAK BOLEH punya TP!
            // Agar saat TP masal disentuh, MT5 hanya menutup posisi yang lain, dan best_ticket tetap hidup sebagai Runner.
            if(group_positions > 1 && ticket == best_ticket)
              {
               target_tp = 0.0; 
              }
            
            if(MathAbs(current_sl - target_sl) > _Point * 0.5 || MathAbs(current_tp - target_tp) > _Point * 0.5)
              {
               trade.PositionModify(ticket, target_sl, target_tp);
              }
           }
        }
     }
  }

void OnTick()
  {
   if(ObjectGetInteger(0, "BtnBuyGrid", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_BUY); }
   if(ObjectGetInteger(0, "BtnSellGrid", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnSellGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_SELL); }
   if(ObjectGetInteger(0, "BtnClosePos", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnClosePos", OBJPROP_STATE, false); ExecuteClosePos(); }
   if(ObjectGetInteger(0, "BtnDelLimit", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnDelLimit", OBJPROP_STATE, false); ExecuteDelLimit(); }
   if(ObjectGetInteger(0, "BtnClearSLTP", OBJPROP_STATE)) { ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_STATE, false); ExecuteClearSLTP(); }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         string order_symbol = OrderGetString(ORDER_SYMBOL);
         if(StringCompare(order_symbol, _Symbol, false) == 0)
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
      if(m == 0) continue; // Abaikan posisi manual
      
      bool already = false;
      for(int j = 0; j < processed_count; j+=2) { if(processed_groups[j] == m && processed_groups[j+1] == type) { already = true; break; } }
      if(already) continue;
      
      processed_groups[processed_count] = m;
      processed_groups[processed_count+1] = type;
      processed_count += 2;
      
      SyncGroupSLTP(m, type);
     }
     
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong t = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      long m = OrderGetInteger(ORDER_MAGIC);
      if(m == 0) continue; // Abaikan limit manual
      
      long o_type = OrderGetInteger(ORDER_TYPE);
      long type = (o_type == ORDER_TYPE_BUY_LIMIT) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
      
      bool already = false;
      for(int j = 0; j < processed_count; j+=2) { if(processed_groups[j] == m && processed_groups[j+1] == type) { already = true; break; } }
      if(already) continue;
      
      processed_groups[processed_count] = m;
      processed_groups[processed_count+1] = type;
      processed_count += 2;
      
      SyncGroupSLTP(m, type);
     }
  }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == "BtnBuyGrid") { ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_BUY); }
      else if(sparam == "BtnSellGrid") { ObjectSetInteger(0, "BtnSellGrid", OBJPROP_STATE, false); ExecuteGrid(ORDER_TYPE_SELL); }
      else if(sparam == "BtnClosePos") { ObjectSetInteger(0, "BtnClosePos", OBJPROP_STATE, false); ExecuteClosePos(); }
      else if(sparam == "BtnDelLimit") { ObjectSetInteger(0, "BtnDelLimit", OBJPROP_STATE, false); ExecuteDelLimit(); }
      else if(sparam == "BtnClearSLTP") { ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_STATE, false); ExecuteClearSLTP(); }
     }
  }
//+------------------------------------------------------------------+