//+------------------------------------------------------------------+
//|                                              Asisten_Grid_Pro_V22|
//| Ultimate XAUUSD: Independent Magic Grids + Smart Auto-Runner     |
//+------------------------------------------------------------------+
#property copyright "Hak Cipta Anda"
#property link      ""
#property version   "22.22" 

#include <Trade\Trade.mqh>
CTrade trade;

// --- PENGATURAN GRID MULTI-INSTRUMEN (SATUAN PIPS) ---
// Catatan: 1 Pip = $0.10 di XAUUSD (Emas) / 0.00010 di EURUSD (Forex 5 Digit).
// Kompatibel: Jika Anda memasukkan format lama (0.4 - 1.8), EA otomatis mengartikannya sebagai (4.0 - 18.0) Pip.
input double InpGridStep1      = 4.0;    // Jarak Layer Lot 1 (Pips)
input int    InpLimitLayer1    = 5;      // Jumlah layer lot pertama
input double InpLot1           = 0.01;   // Lot pertama

input double InpGridStep2      = 6.0;    // Jarak Layer Lot 2 (Pips)
input int    InpLimitLayer2    = 6;      // Jumlah layer lot kedua
input double InpLot2           = 0.02;   // Lot kedua

input double InpGridStep3      = 8.0;    // Jarak Layer Lot 3 (Pips)
input int    InpLimitLayer3    = 7;      // Jumlah layer lot ketiga
input double InpLot3           = 0.03;   // Lot ketiga

input double InpGridStep4      = 10.0;   // Jarak Layer Lot 4 (Pips)
input int    InpLimitLayer4    = 1;      // Jumlah layer lot keempat
input double InpLot4           = 0.04;   // Lot keempat

input double InpGridStep5      = 12.0;   // Jarak Layer Lot 5 (Pips)
input int    InpLimitLayer5    = 1;      // Jumlah layer lot kelima
input double InpLot5           = 0.05;   // Lot kelima

input double InpGridStep6      = 14.0;   // Jarak Layer Lot 6 (Pips)
input int    InpLimitLayer6    = 1;      // Jumlah layer lot keenam
input double InpLot6           = 0.06;   // Lot keenam

input double InpGridStep7      = 16.0;   // Jarak Layer Lot 7 (Pips)
input int    InpLimitLayer7    = 1;      // Jumlah layer lot ketujuh
input double InpLot7           = 0.07;   // Lot ketujuh

input double InpGridStep8      = 18.0;   // Jarak Layer Lot 8 (Pips)
input int    InpLimitLayer8    = 1;      // Jumlah layer lot kedelapan
input double InpLot8           = 0.08;   // Lot kedelapan

input double InpAutoTPDistance = 50.0;   // Jarak Auto TP (Pips) - Selalu Aktif
input bool   InpUseAutoSL      = false;  // Gunakan Auto SL di akhir layer
input double InpAutoSLDistance = 5.0;    // Jarak Auto SL dari layer terakhir (Pips)
input double InpRunnerBEPips   = 0.3;    // Jarak Kunci BE+ Runner (Pips)

//+------------------------------------------------------------------+
//| Mengambil ukuran 1 Pip sesuai instrumen (Forex vs Logam/Emas)    |
//+------------------------------------------------------------------+
double GetPipSize()
  {
   string sym = _Symbol;
   StringToUpper(sym);
   
   // XAUUSD / GOLD (Logam Mulia)
   if(StringFind(sym, "XAU") >= 0 || StringFind(sym, "GOLD") >= 0)
     {
      if(_Digits == 2) return 0.10;
      if(_Digits == 3) return 0.10;
      return 10.0 * _Point;
     }
     
   // Forex 5 Digit & 3 Digit (JPY)
   if(_Digits == 5 || _Digits == 3)
     {
      return 10.0 * _Point;
     }
     
   // Forex 4 Digit & 2 Digit
   if(_Digits == 4 || _Digits == 2)
     {
      return _Point;
     }
     
   return _Point;
  }

//+------------------------------------------------------------------+
//| Menstandarisasi input step ke satuan Pips                        |
//+------------------------------------------------------------------+
double GetPipStep(double step_input)
  {
   if(step_input > 0.0 && step_input < 2.0)
     {
      return step_input * 10.0;
     }
   return step_input;
  }

// --- VARIABEL GLOBAL ---
ulong last_processed_ticket = 0; 

//+------------------------------------------------------------------+
//| Membuat & Memperbarui Mini Info-Panel serta Garis Visual BEP     |
//+------------------------------------------------------------------+
void UpdateVisualDashboard()
  {
   double total_lots   = 0.0;
   int    total_layers = 0;
   double buy_lots     = 0.0;
   double sell_lots    = 0.0;
   double sum_buy_val  = 0.0;
   double sum_sell_val = 0.0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         double lot   = PositionGetDouble(POSITION_VOLUME);
         double price = PositionGetDouble(POSITION_PRICE_OPEN);
         long   type  = PositionGetInteger(POSITION_TYPE);

         total_lots += lot;
         total_layers++;

         if(type == POSITION_TYPE_BUY)
           {
            buy_lots    += lot;
            sum_buy_val += (lot * price);
           }
         else if(type == POSITION_TYPE_SELL)
           {
            sell_lots    += lot;
            sum_sell_val += (lot * price);
           }
        }
     }

   // Hitung Harga BEP (Weighted Average Price)
   double bep_price = 0.0;
   double net_lots  = buy_lots - sell_lots;
   if(total_layers > 0 && MathAbs(net_lots) > 0.00001)
     {
      bep_price = (sum_buy_val - sum_sell_val) / net_lots;
     }

   // 1. Kelola Garis Visual BEP Line di Chart
   string bep_line_name = "GridV22_BEPLine";
   if(total_layers > 0 && bep_price > 0.0)
     {
      if(ObjectFind(0, bep_line_name) < 0)
        {
         ObjectCreate(0, bep_line_name, OBJ_HLINE, 0, 0, bep_price);
         ObjectSetInteger(0, bep_line_name, OBJPROP_COLOR, clrGold);
         ObjectSetInteger(0, bep_line_name, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, bep_line_name, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, bep_line_name, OBJPROP_BACK, false);
         ObjectSetInteger(0, bep_line_name, OBJPROP_SELECTABLE, false);
        }
      ObjectSetDouble(0, bep_line_name, OBJPROP_PRICE, NormalizeDouble(bep_price, _Digits));
      ObjectSetString(0, bep_line_name, OBJPROP_TOOLTIP, "BEP Price: " + DoubleToString(bep_price, _Digits));
     }
   else
     {
      if(ObjectFind(0, bep_line_name) >= 0) ObjectDelete(0, bep_line_name);
     }

   // 2. Pengaturan Ukuran & Posisi Panel di Kanan Atas (Di bawah tulisan Asisten_Grid_Pro)
   int panel_width  = 350;
   int panel_height = 82;
   int right_margin = 10;
   int top_margin   = 28;
   int panel_x_dist = panel_width + right_margin;
   int text_x_dist  = panel_x_dist - 14;

   if(ObjectFind(0, "GridV22_PanelBG") < 0)
      ObjectCreate(0, "GridV22_PanelBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_XDISTANCE, panel_x_dist);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_YDISTANCE, top_margin);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_XSIZE, panel_width);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_YSIZE, panel_height);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_BGCOLOR, C'22,26,35');
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_COLOR, clrDodgerBlue);
   ObjectSetInteger(0, "GridV22_PanelBG", OBJPROP_SELECTABLE, false);

   if(ObjectFind(0, "GridV22_LblLot") < 0)
      ObjectCreate(0, "GridV22_LblLot", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GridV22_LblLot", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "GridV22_LblLot", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, "GridV22_LblLot", OBJPROP_XDISTANCE, text_x_dist);
   ObjectSetInteger(0, "GridV22_LblLot", OBJPROP_YDISTANCE, top_margin + 8);
   ObjectSetString(0, "GridV22_LblLot", OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, "GridV22_LblLot", OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, "GridV22_LblLot", OBJPROP_COLOR, clrWhite);

   if(ObjectFind(0, "GridV22_LblLayer") < 0)
      ObjectCreate(0, "GridV22_LblLayer", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GridV22_LblLayer", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "GridV22_LblLayer", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, "GridV22_LblLayer", OBJPROP_XDISTANCE, text_x_dist);
   ObjectSetInteger(0, "GridV22_LblLayer", OBJPROP_YDISTANCE, top_margin + 31);
   ObjectSetString(0, "GridV22_LblLayer", OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, "GridV22_LblLayer", OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, "GridV22_LblLayer", OBJPROP_COLOR, clrWhite);

   if(ObjectFind(0, "GridV22_LblBEP") < 0)
      ObjectCreate(0, "GridV22_LblBEP", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "GridV22_LblBEP", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, "GridV22_LblBEP", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, "GridV22_LblBEP", OBJPROP_XDISTANCE, text_x_dist);
   ObjectSetInteger(0, "GridV22_LblBEP", OBJPROP_YDISTANCE, top_margin + 54);
   ObjectSetString(0, "GridV22_LblBEP", OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, "GridV22_LblBEP", OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, "GridV22_LblBEP", OBJPROP_COLOR, clrGold);

   // 3. Perbarui Teks pada Mini Info-Panel
   ObjectSetString(0, "GridV22_LblLot", OBJPROP_TEXT, "Total Lot Aktif : " + DoubleToString(total_lots, 2) + " Lot");
   ObjectSetString(0, "GridV22_LblLayer", OBJPROP_TEXT, "Layer Terbuka   : " + IntegerToString(total_layers) + " Layer");

   if(total_layers > 0 && bep_price > 0.0)
     {
      double ref_price = (net_lots > 0.0) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double dist_pips = MathAbs(ref_price - bep_price) / GetPipSize();
      string bep_text  = "Harga ke BEP    : " + DoubleToString(bep_price, _Digits) + " (" + DoubleToString(dist_pips, 1) + "p)";
      ObjectSetString(0, "GridV22_LblBEP", OBJPROP_TEXT, bep_text);
     }
   else
     {
      ObjectSetString(0, "GridV22_LblBEP", OBJPROP_TEXT, "Harga ke BEP    : -");
     }

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectCreate(0, "BtnBuyGrid", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnBuyGrid", OBJPROP_TEXT, "B");
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_BGCOLOR, clrDodgerBlue);
   ObjectSetInteger(0, "BtnBuyGrid", OBJPROP_COLOR, clrWhite);
   
   ObjectCreate(0, "BtnSellGrid", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_XDISTANCE, 70); 
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnSellGrid", OBJPROP_TEXT, "S");
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_BGCOLOR, clrCrimson);
   ObjectSetInteger(0, "BtnSellGrid", OBJPROP_COLOR, clrWhite);

   // Tombol "C" kini berfungsi sebagai Instant Runner (Close All Except Runner)
   ObjectCreate(0, "BtnClosePos", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnClosePos", OBJPROP_TEXT, "C");
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_BGCOLOR, clrGoldenrod);
   ObjectSetInteger(0, "BtnClosePos", OBJPROP_COLOR, clrWhite);

   ObjectCreate(0, "BtnDelLimit", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_XDISTANCE, 170);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnDelLimit", OBJPROP_TEXT, "X");
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_BGCOLOR, clrDimGray);
   ObjectSetInteger(0, "BtnDelLimit", OBJPROP_COLOR, clrWhite);
   
   ObjectCreate(0, "BtnClearSLTP", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_XDISTANCE, 220);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_YDISTANCE, 100); 
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_XSIZE, 40);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_YSIZE, 40);
   ObjectSetString(0, "BtnClearSLTP", OBJPROP_TEXT, "CL");
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_BGCOLOR, clrDarkViolet);
   ObjectSetInteger(0, "BtnClearSLTP", OBJPROP_COLOR, clrWhite);

   UpdateVisualDashboard();

   Print("Asisten Grid V22.22 Multi-Instrument (Tombol C = Instant Runner) Aktif pada: ", _Symbol);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   ObjectDelete(0, "BtnBuyGrid");
   ObjectDelete(0, "BtnSellGrid");
   ObjectDelete(0, "BtnClosePos");
   ObjectDelete(0, "BtnDelLimit");
   ObjectDelete(0, "BtnClearSLTP");
   ObjectDelete(0, "GridV22_BEPLine");
   ObjectDelete(0, "GridV22_PanelBG");
   ObjectDelete(0, "GridV22_LblLot");
   ObjectDelete(0, "GridV22_LblLayer");
   ObjectDelete(0, "GridV22_LblBEP");
  }

//+------------------------------------------------------------------+
//| Memastikan posisi Runner selalu memiliki TP=0 dan SL di BE+      |
//+------------------------------------------------------------------+
void EnforceRunnerProtection(ulong ticket)
  {
   if(ticket == 0 || !PositionSelectByTicket(ticket)) return;
   if(PositionGetString(POSITION_SYMBOL) != _Symbol) return;

   long pos_type = PositionGetInteger(POSITION_TYPE);
   double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
   double current_sl = PositionGetDouble(POSITION_SL);
   double current_tp = PositionGetDouble(POSITION_TP);

   double stop_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double be_offset  = InpRunnerBEPips * GetPipSize();

   double target_sl = current_sl;
   bool need_be_update = false;

   if(pos_type == POSITION_TYPE_BUY)
     {
      double target_be = NormalizeDouble(open_price + be_offset, _Digits);
      if(current_sl < target_be - _Point * 0.5)
        {
         if(SymbolInfoDouble(_Symbol, SYMBOL_BID) - target_be > stop_level)
           {
            target_sl = target_be;
            need_be_update = true;
           }
        }
     }
   else if(pos_type == POSITION_TYPE_SELL)
     {
      double target_be = NormalizeDouble(open_price - be_offset, _Digits);
      if(current_sl == 0.0 || current_sl > target_be + _Point * 0.5)
        {
         if(target_be - SymbolInfoDouble(_Symbol, SYMBOL_ASK) > stop_level)
           {
            target_sl = target_be;
            need_be_update = true;
           }
        }
     }

   if(current_tp > 0.0 || need_be_update)
     {
      if(!trade.PositionModify(ticket, target_sl, 0.0))
        {
         if(current_tp > 0.0) trade.PositionModify(ticket, current_sl, 0.0);
        }
     }
  }

//+------------------------------------------------------------------+
//| Fase Eksekusi Runner: Prioritaskan penyelamatan Runner di awal   |
//+------------------------------------------------------------------+
void ExecuteRunnerPhase(long magic, long type)
  {
   if(magic == 0) return;
   
   string lock_name = "GridV22_RunnerLock_" + IntegerToString(magic);
   if(GlobalVariableCheck(lock_name)) return; 
   GlobalVariableSet(lock_name, 1.0); 
   
   // 1. Cari posisi terbaik yang MASIH HIDUP
   ulong best_ticket = 0;
   double best_price = (type == POSITION_TYPE_BUY) ? 999999999.0 : 0.0;
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
           }
        }
     }
     
   if(group_positions == 0 || best_ticket == 0)
     {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic)
            trade.OrderDelete(ticket);
        }
      GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_HadPositions");
      GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_SL");
      GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_TP");
      GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_SyncLock");
      GlobalVariableDel(lock_name);
      return;
     }

   // 2. PRIORITAS PERTAMA: Amankan Runner (Hapus TP & Pasang BE+ sesuai InpRunnerBEPips)
   string gv_runner = "GridV22_" + IntegerToString(magic) + "_RunnerTicket";
   GlobalVariableSet(gv_runner, (double)best_ticket);
   EnforceRunnerProtection(best_ticket);

   // 3. Hapus tracking SL/TP grup agar Auto-Sync tidak mengembalikan TP ke Runner
   GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_SL");
   GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_TP");

   // 4. Tutup semua posisi lain KECUALI best_ticket (Runner)
   if(group_positions > 1)
     {
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
     }
     
   // 5. Bersihkan seluruh sisa limit orders pada grup ini
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic)
        {
         trade.OrderDelete(ticket);
        }
     }
  }

void CleanupMemory()
  {
   static datetime last_clean_time = 0;
   datetime now = TimeCurrent();
   if(now != last_clean_time)
     {
      last_clean_time = now;
      for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
        {
         string name = GlobalVariableName(i);
         if(StringFind(name, "GridV22_RunnerLock_") == 0)
           {
            string parts[];
            StringSplit(name, '_', parts);
            long m = 0;
            if(ArraySize(parts) == 3) m = StringToInteger(parts[2]);
            
            if(m != 0)
              {
               for(int o = OrdersTotal() - 1; o >= 0; o--)
                 {
                  ulong t = OrderGetTicket(o);
                  if(OrderSelect(t) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == m)
                    {
                     trade.OrderDelete(t);
                    }
                 }
              }
           }
        }
     }

   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
     {
      string name = GlobalVariableName(i);
      if(StringFind(name, "GridV22_") == 0)
        {
         string parts[];
         StringSplit(name, '_', parts);
         long m = 0;
         
         if(ArraySize(parts) == 3 && (parts[2] == "SL" || parts[2] == "TP" || parts[2] == "HadPositions")) m = StringToInteger(parts[1]);
         if(ArraySize(parts) == 3 && (parts[1] == "RunnerLock" || parts[1] == "SyncLock" || parts[1] == "RunnerTicket")) m = StringToInteger(parts[2]); 
         
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
         long entry = HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
         if(entry == DEAL_ENTRY_OUT)
           {
            long magic = HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
            if(magic == 0)
              {
               long pos_id = HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
               if(pos_id > 0 && HistorySelectByPosition(pos_id))
                 {
                  for(int d = HistoryDealsTotal() - 1; d >= 0; d--)
                    {
                     ulong dt = HistoryDealGetTicket(d);
                     if(dt > 0 && HistoryDealGetInteger(dt, DEAL_ENTRY) == DEAL_ENTRY_IN)
                       {
                        magic = HistoryDealGetInteger(dt, DEAL_MAGIC);
                        if(magic != 0) break;
                       }
                    }
                 }
              }
            
            if(magic != 0 && HistoryDealGetString(deal_ticket, DEAL_SYMBOL) == _Symbol)
              {
               int remaining_pos = 0;
               for(int p = 0; p < PositionsTotal(); p++)
                 {
                  ulong pt = PositionGetTicket(p);
                  if(PositionSelectByTicket(pt) && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic)
                    {
                     remaining_pos++;
                    }
                 }
               
               if(remaining_pos == 0)
                 {
                  for(int o = OrdersTotal() - 1; o >= 0; o--)
                    {
                     ulong ot = OrderGetTicket(o);
                     if(OrderSelect(ot) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic)
                       {
                        trade.OrderDelete(ot);
                       }
                    }
                  GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_HadPositions");
                  GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_SL");
                  GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_TP");
                  GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_SyncLock");
                  GlobalVariableDel("GridV22_RunnerLock_" + IntegerToString(magic));
                  GlobalVariableDel("GridV22_" + IntegerToString(magic) + "_RunnerTicket");
                 }
               else
                 {
                  long reason = HistoryDealGetInteger(deal_ticket, DEAL_REASON);
                  double profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
                  string gv_tp = "GridV22_" + IntegerToString(magic) + "_TP";
                  bool had_tp = GlobalVariableCheck(gv_tp);
                  
                  if(reason == DEAL_REASON_TP || (profit > 0.0 && had_tp))
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
  }

//+------------------------------------------------------------------+
//| Tombol "C": Tutup posisi lain, sisakan Runner (BE+) & hapus Limit|
//+------------------------------------------------------------------+
void ExecuteClosePos() 
  { 
   long groups_magic[100];
   long groups_type[100];
   int  groups_count = 0;

   // 1. Kumpulkan seluruh grup aktif pada simbol ini
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         long m = PositionGetInteger(POSITION_MAGIC);
         long t = PositionGetInteger(POSITION_TYPE);
         if(m == 0) continue;

         bool exists = false;
         for(int j = 0; j < groups_count; j++)
           {
            if(groups_magic[j] == m && groups_type[j] == t) { exists = true; break; }
           }
         if(!exists && groups_count < 100)
           {
            groups_magic[groups_count] = m;
            groups_type[groups_count]  = t;
            groups_count++;
           }
        }
     }

   // 2. Jalankan Fase Runner pada setiap grup (Tutup semua posisi kecuali 1 Runner terbaik & pasang BE+)
   for(int j = 0; j < groups_count; j++)
     {
      string lock_name = "GridV22_RunnerLock_" + IntegerToString(groups_magic[j]);
      if(GlobalVariableCheck(lock_name)) GlobalVariableDel(lock_name);
      ExecuteRunnerPhase(groups_magic[j], groups_type[j]);
     }

   // 3. Bersihkan seluruh sisa pending limit order pada simbol ini
   ExecuteDelLimit();
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
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
     {
      string name = GlobalVariableName(i);
      if(StringFind(name, "GridV21_") == 0 || StringFind(name, "GridV20_") == 0 || StringFind(name, "GridV22_") == 0) GlobalVariableDel(name);
     }
     
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         trade.PositionModify(ticket, 0.0, 0.0);
        }
     }
     
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         trade.OrderModify(ticket, OrderGetDouble(ORDER_PRICE_OPEN), 0.0, 0.0, ORDER_TIME_GTC, 0);
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

double GetStepDistance(int layer_index)
  {
   double step_pips = 0.0;
   if (layer_index <= InpLimitLayer1) step_pips = GetPipStep(InpGridStep1);
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2) step_pips = GetPipStep(InpGridStep2);
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3) step_pips = GetPipStep(InpGridStep3);
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4) step_pips = GetPipStep(InpGridStep4);
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5) step_pips = GetPipStep(InpGridStep5);
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6) step_pips = GetPipStep(InpGridStep6);
   else if (layer_index <= InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6 + InpLimitLayer7) step_pips = GetPipStep(InpGridStep7);
   else step_pips = GetPipStep(InpGridStep8);
   
   return step_pips * GetPipSize();
  }

double GetDistanceForLayer(int layer_index)
  {
   double total_distance = 0.0;
   for(int i = 1; i <= layer_index; i++)
     {
      total_distance += GetStepDistance(i);
     }
   return total_distance;
  }

void ExecuteGridFromPrice(int limit_type, double base_price, double manual_sl, double manual_tp)
  {
   int total_layers = InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6 + InpLimitLayer7 + InpLimitLayer8; 
   ulong current_magic = (ulong)GetTickCount64(); 
   trade.SetExpertMagicNumber(current_magic);
   
   double total_dist = GetDistanceForLayer(total_layers);
   double auto_sl_dist = InpAutoSLDistance * GetPipSize();
   double auto_sl = 0.0;
   double auto_tp = 0.0;
   
   if(limit_type == ORDER_TYPE_BUY_LIMIT)
     {
      if(manual_sl > 0.0) auto_sl = manual_sl;
      else if(InpUseAutoSL) auto_sl = NormalizeDouble(base_price - total_dist - auto_sl_dist, _Digits);
      
      if(manual_tp > 0.0) auto_tp = manual_tp;
      else if(InpAutoTPDistance > 0.0) auto_tp = NormalizeDouble(base_price + InpAutoTPDistance * GetPipSize(), _Digits);
      
      if(auto_tp > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_TP", auto_tp);
      if(auto_sl > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_SL", auto_sl);
      
      for(int i = 0; i <= total_layers; i++)
        {
         double lot = (i == 0) ? InpLot1 : GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(base_price - current_distance, _Digits);
         trade.BuyLimit(lot, limit_price, _Symbol, auto_sl, auto_tp, ORDER_TIME_GTC, 0, "Grid Catch");
        }
     }
   else if(limit_type == ORDER_TYPE_SELL_LIMIT)
     {
      if(manual_sl > 0.0) auto_sl = manual_sl;
      else if(InpUseAutoSL) auto_sl = NormalizeDouble(base_price + total_dist + auto_sl_dist, _Digits);
      
      if(manual_tp > 0.0) auto_tp = manual_tp;
      else if(InpAutoTPDistance > 0.0) auto_tp = NormalizeDouble(base_price - InpAutoTPDistance * GetPipSize(), _Digits);
      
      if(auto_tp > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_TP", auto_tp);
      if(auto_sl > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_SL", auto_sl);
      
      for(int i = 0; i <= total_layers; i++)
        {
         double lot = (i == 0) ? InpLot1 : GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(base_price + current_distance, _Digits);
         trade.SellLimit(lot, limit_price, _Symbol, auto_sl, auto_tp, ORDER_TIME_GTC, 0, "Grid Catch");
        }
     }
  }

void ExecuteGrid(int direction)
  {
   int total_layers = InpLimitLayer1 + InpLimitLayer2 + InpLimitLayer3 + InpLimitLayer4 + InpLimitLayer5 + InpLimitLayer6 + InpLimitLayer7 + InpLimitLayer8; 
   ulong current_magic = (ulong)GetTickCount64(); 
   trade.SetExpertMagicNumber(current_magic);
   
   double total_dist = GetDistanceForLayer(total_layers);
   double auto_sl_dist = InpAutoSLDistance * GetPipSize();
   double auto_sl = 0.0;
   double auto_tp = 0.0;
   
   if(direction == ORDER_TYPE_BUY)
     {
      double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(InpUseAutoSL) auto_sl = NormalizeDouble(Ask - total_dist - auto_sl_dist, _Digits);
      if(InpAutoTPDistance > 0.0) auto_tp = NormalizeDouble(Ask + InpAutoTPDistance * GetPipSize(), _Digits);
      
      if(auto_tp > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_TP", auto_tp);
      if(auto_sl > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_SL", auto_sl);
      GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_HadPositions", 1.0);
      
      trade.Buy(InpLot1, _Symbol, Ask, auto_sl, auto_tp, "Grid BUY");
      for(int i = 1; i <= total_layers; i++)
        {
         double lot = GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(Ask - current_distance, _Digits);
         trade.BuyLimit(lot, limit_price, _Symbol, auto_sl, auto_tp, ORDER_TIME_GTC, 0, "Grid Buy Limit");
        }
     }
   else if(direction == ORDER_TYPE_SELL)
     {
      double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(InpUseAutoSL) auto_sl = NormalizeDouble(Bid + total_dist + auto_sl_dist, _Digits);
      if(InpAutoTPDistance > 0.0) auto_tp = NormalizeDouble(Bid - InpAutoTPDistance * GetPipSize(), _Digits);
      
      if(auto_tp > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_TP", auto_tp);
      if(auto_sl > 0.0) GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_SL", auto_sl);
      GlobalVariableSet("GridV22_" + IntegerToString(current_magic) + "_HadPositions", 1.0);
      
      trade.Sell(InpLot1, _Symbol, Bid, auto_sl, auto_tp, "Grid SELL");
      for(int i = 1; i <= total_layers; i++)
        {
         double lot = GetLotForLayer(i);
         double current_distance = GetDistanceForLayer(i);
         double limit_price = NormalizeDouble(Bid + current_distance, _Digits);
         trade.SellLimit(lot, limit_price, _Symbol, auto_sl, auto_tp, ORDER_TIME_GTC, 0, "Grid Sell Limit");
        }
     }
  }

void SyncGroupSLTP(long magic, long type)
  {
   if(magic == 0) return;
   
   // JIKA GRUP SUDAH MASUK MODE RUNNER, KAWAL POSISI RUNNER (TP=0 & SL=BE+)
   string runner_lock = "GridV22_RunnerLock_" + IntegerToString(magic);
   if(GlobalVariableCheck(runner_lock))
     {
      string gv_runner = "GridV22_" + IntegerToString(magic) + "_RunnerTicket";
      if(GlobalVariableCheck(gv_runner))
        {
         ulong rt = (ulong)GlobalVariableGet(gv_runner);
         EnforceRunnerProtection(rt);
        }
      return;
     }
   
   string gv_sl = "GridV22_" + IntegerToString(magic) + "_SL";
   string gv_tp = "GridV22_" + IntegerToString(magic) + "_TP";
   
   double last_known_sl = GlobalVariableCheck(gv_sl) ? GlobalVariableGet(gv_sl) : 0.0;
   double last_known_tp = GlobalVariableCheck(gv_tp) ? GlobalVariableGet(gv_tp) : 0.0;
   
   double current_bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double current_ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double pip_size    = GetPipSize();

   // ANTI-TP-KILLER: Bekukan sinkronisasi jika harga sudah masuk radius eksekusi Runner (0.5 Pip dari TP)
   if(last_known_tp > 0.0)
     {
      double trigger_dist = 0.5 * pip_size;
      if(type == POSITION_TYPE_BUY && current_bid >= last_known_tp - trigger_dist) return;
      if(type == POSITION_TYPE_SELL && current_ask <= last_known_tp + trigger_dist) return;
     }

   bool sl_changed = false;
   bool tp_changed = false;
   double new_sl = last_known_sl;
   double new_tp = last_known_tp;
   
   string lock_name = "GridV22_SyncLock_" + IntegerToString(magic);
   datetime lock_time = GlobalVariableCheck(lock_name) ? (datetime)GlobalVariableGet(lock_name) : 0;
   datetime current_time = TimeCurrent();
   bool can_detect = (current_time > lock_time);
   
   ulong best_ticket = 0;
   double best_price = (type == POSITION_TYPE_BUY) ? 999999999.0 : 0.0;
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
            
            if(can_detect)
              {
               double pos_sl = PositionGetDouble(POSITION_SL);
               double pos_tp = PositionGetDouble(POSITION_TP);
               if(pos_sl > 0.0 && MathAbs(pos_sl - last_known_sl) > _Point * 0.5) { new_sl = pos_sl; sl_changed = true; }
               if(pos_tp > 0.0 && MathAbs(pos_tp - last_known_tp) > _Point * 0.5) { new_tp = pos_tp; tp_changed = true; }
              }
           }
        }
     }
     
   if(can_detect)
     {
      for(int i = 0; i < OrdersTotal(); i++)
        {
         ulong ticket = OrderGetTicket(i);
         if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic)
           {
            double pos_sl = OrderGetDouble(ORDER_SL);
            double pos_tp = OrderGetDouble(ORDER_TP);
            if(pos_sl > 0.0 && MathAbs(pos_sl - last_known_sl) > _Point * 0.5) { new_sl = pos_sl; sl_changed = true; }
            if(pos_tp > 0.0 && MathAbs(pos_tp - last_known_tp) > _Point * 0.5) { new_tp = pos_tp; tp_changed = true; }
           }
        }
     }
     
   if(sl_changed || tp_changed)
     {
      if(sl_changed) GlobalVariableSet(gv_sl, new_sl);
      if(tp_changed) GlobalVariableSet(gv_tp, new_tp);
      GlobalVariableSet(lock_name, (double)(current_time + 2)); 
     }

   // PRE-SHIELD RUNNER: Jika harga mendekati TP (<= 5 Pips dari TP), lepas TP server HANYA pada best_ticket
   bool shield_best_ticket = false;
   if(new_tp > 0.0 && best_ticket > 0)
     {
      double shield_dist = 5.0 * pip_size;
      if(type == POSITION_TYPE_BUY && current_bid >= new_tp - shield_dist) shield_best_ticket = true;
      if(type == POSITION_TYPE_SELL && current_ask <= new_tp + shield_dist) shield_best_ticket = true;
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
            
            if(ticket == best_ticket && shield_best_ticket)
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
     
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic)
        {
         double current_sl = OrderGetDouble(ORDER_SL);
         double current_tp = OrderGetDouble(ORDER_TP);
         double target_sl = (new_sl > 0.0) ? new_sl : current_sl;
         double target_tp = (new_tp > 0.0) ? new_tp : current_tp;
         
         long order_type = OrderGetInteger(ORDER_TYPE);
         double open_price = OrderGetDouble(ORDER_PRICE_OPEN);
         
         bool should_delete = false;
         if(order_type == ORDER_TYPE_BUY_LIMIT && target_sl >= open_price) should_delete = true;
         if(order_type == ORDER_TYPE_SELL_LIMIT && target_sl > 0.0 && target_sl <= open_price) should_delete = true;
         if(order_type == ORDER_TYPE_BUY_LIMIT && target_tp > 0.0 && target_tp <= open_price) should_delete = true;
         if(order_type == ORDER_TYPE_SELL_LIMIT && target_tp > 0.0 && target_tp >= open_price) should_delete = true;
         
         if(should_delete)
           {
            trade.OrderDelete(ticket);
            continue;
           }
         
         if(MathAbs(current_sl - target_sl) > _Point * 0.5 || MathAbs(current_tp - target_tp) > _Point * 0.5)
           {
            trade.OrderModify(ticket, open_price, target_sl, target_tp, ORDER_TIME_GTC, 0);
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
                  double manual_sl = OrderGetDouble(ORDER_SL);
                  double manual_tp = OrderGetDouble(ORDER_TP); 
                  if(trade.OrderDelete(ticket)) 
                    {
                     last_processed_ticket = ticket; 
                     ExecuteGridFromPrice((int)type, manual_price, manual_sl, manual_tp); 
                    }
                 }
              }
           }
        }
     }
     
   CleanupMemory();

   // 1. Pantau grup yang sebelumnya memiliki posisi. Jika semua posisi ditutup langsung, bersihkan limit order seketika
   for(int i = GlobalVariablesTotal() - 1; i >= 0; i--)
     {
      string name = GlobalVariableName(i);
      if(StringFind(name, "GridV22_") == 0 && StringFind(name, "_HadPositions") > 0)
        {
         string parts[];
         StringSplit(name, '_', parts);
         if(ArraySize(parts) == 3 && parts[2] == "HadPositions")
           {
            long m = StringToInteger(parts[1]);
            if(m != 0)
              {
               int p_count = 0;
               for(int p = 0; p < PositionsTotal(); p++)
                 {
                  ulong pt = PositionGetTicket(p);
                  if(PositionSelectByTicket(pt) && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == m)
                    {
                     p_count++;
                    }
                 }
               if(p_count == 0)
                 {
                  for(int o = OrdersTotal() - 1; o >= 0; o--)
                    {
                     ulong ot = OrderGetTicket(o);
                     if(OrderSelect(ot) && OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == m)
                       {
                        trade.OrderDelete(ot);
                       }
                    }
                  GlobalVariableDel(name);
                  GlobalVariableDel("GridV22_" + IntegerToString(m) + "_SL");
                  GlobalVariableDel("GridV22_" + IntegerToString(m) + "_TP");
                  GlobalVariableDel("GridV22_" + IntegerToString(m) + "_SyncLock");
                  GlobalVariableDel("GridV22_RunnerLock_" + IntegerToString(m));
                  GlobalVariableDel("GridV22_" + IntegerToString(m) + "_RunnerTicket");
                 }
              }
           }
        }
     }

   long processed_groups[100];
   int processed_count = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong t = PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      long m = PositionGetInteger(POSITION_MAGIC);
      long type = PositionGetInteger(POSITION_TYPE);
      if(m == 0) continue;
      
      string gv_had = "GridV22_" + IntegerToString(m) + "_HadPositions";
      if(!GlobalVariableCheck(gv_had)) GlobalVariableSet(gv_had, 1.0);
      
      bool already = false;
      for(int j = 0; j < processed_count; j+=2) { if(processed_groups[j] == m && processed_groups[j+1] == type) { already = true; break; } }
      if(already) continue;
      
      processed_groups[processed_count] = m;
      processed_groups[processed_count+1] = type;
      processed_count += 2;
      
      // JIKA SUDAH RUNNER LOCK, PASTIKAN PROTEKSI RUNNER SELALU TERJAGA
      string lock_name = "GridV22_RunnerLock_" + IntegerToString(m);
      if(GlobalVariableCheck(lock_name))
        {
         string gv_runner = "GridV22_" + IntegerToString(m) + "_RunnerTicket";
         if(GlobalVariableCheck(gv_runner))
           {
            EnforceRunnerProtection((ulong)GlobalVariableGet(gv_runner));
           }
         continue;
        }
      
      // DETEKSI HARGA HIT TP SECARA LANGSUNG PADA TICK
      string gv_tp = "GridV22_" + IntegerToString(m) + "_TP";
      if(GlobalVariableCheck(gv_tp))
        {
         double group_tp = GlobalVariableGet(gv_tp);
         if(group_tp > 0.0)
           {
            double current_bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double current_ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double trigger_dist = 0.5 * GetPipSize();
            if((type == POSITION_TYPE_BUY && current_bid >= group_tp - trigger_dist) ||
               (type == POSITION_TYPE_SELL && current_ask <= group_tp + trigger_dist))
              {
               ExecuteRunnerPhase(m, type);
               continue;
              }
           }
        }
      
      SyncGroupSLTP(m, type);
     }
     
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong t = OrderGetTicket(i);
      if(!OrderSelect(t)) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      long m = OrderGetInteger(ORDER_MAGIC);
      if(m == 0) continue;
      
      string lock_name = "GridV22_RunnerLock_" + IntegerToString(m);
      if(GlobalVariableCheck(lock_name)) continue;
      
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

   // Perbarui Garis BEP & Mini Info-Panel pada setiap Tick
   UpdateVisualDashboard();
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
      UpdateVisualDashboard();
     }
  }
//+------------------------------------------------------------------+