//+------------------------------------------------------------------+
//|                                              ZTrend_NearLine.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
double ExtMapBuffer0[];
/**
 * 外部参数
 */
extern int  line_type   = 1;   //如果是1 则返回底底线的值，如果是2，则返回底顶线的值

  int OnInit()
  {
  
   
   // draw_d_high_line();
   // draw_d_low_line();
   IndicatorBuffers(5);
   SetIndexBuffer(0,ExtMapBuffer0);//设置缓冲区的值

   return(INIT_SUCCEEDED);
  }
  
  int hour = Hour();
  int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
  
    //算法说明
    //1 当前最近的一个低点和 （其他低点中比他低的中的与他挨的最近的低点）的连线。
    //2 当前最近的一个高点和  （其他高点中比他高的中的与他挨的最近的高点）的连线。
    
    //算法步骤
    //1 找到当前最近的一个低点 ，接着往前找，直到找到比他更低的低点结束
    //2 找到当前最近的一个高点 , 接着往前找，直接找到比他更高的高点结束
  
   
   int cur_hour = Hour();
   if(cur_hour != hour){
        ObjectDelete("trend_high");
        ObjectDelete("trend_low");
        draw_high_line();
        draw_low_line();
        hour = cur_hour;
   }
   
   if(line_type == 1){
      ExtMapBuffer0[0] =  ObjectGetValueByShift("trend_high",1);//返回tlA1的当前所处价位
   }
   if(line_type == 2){
      ExtMapBuffer0[0] =  ObjectGetValueByShift("trend_low",1);//返回tlA1的当前所处价位
   }
  
   return(rates_total);
  }
  
  /**
   * 画高线
   */
   
  int draw_high_line(){
    
    // 1 从第四个柱子到第14个柱子中寻找最高点，如果存在，则找到点1，如果不存在，则从4-15个柱子中找，一直到最近的一个最高点存现为止。
    
    // 2 搜索其他高点，一直到找到比点1 高的点为止。
    
    int shift1 = iHighest(Symbol(),Period(),MODE_HIGH,15,4);
    if(is_high_point(shift1) == false){
      search_high_point(shift1);
    }
    
    int shift2 = iHighest(Symbol(),Period(),MODE_HIGH,30,shift1+1);
    if(is_high_point(shift2) == false){
      search_high_point(shift2);
    }
    
    int shift3 = iHighest(Symbol(),Period(),MODE_HIGH,30,shift2+1);
    if(is_high_point(shift3) == false){
      search_high_point(shift3);
    }

    datetime time1 = iTime(Symbol(),Period(),shift1);
    double price1  = iHigh(Symbol(),Period(),shift1);
    
    datetime time2 = iTime(Symbol(),Period(),shift2);
    double price2 = iHigh(Symbol(),Period(),shift2);
    
    datetime time3 = iTime(Symbol(),Period(),shift3);
    double price3 = iHigh(Symbol(),Period(),shift3);
  
    ObjectCreate("trend_high",OBJ_TREND,0,time3,price3,time2,price2);
    
    datetime t1 = ObjectGet("trend_high",OBJPROP_TIME1);
    datetime t2 = ObjectGet("trend_high",OBJPROP_TIME2);
    
    double p1 = ObjectGet("trend_high",OBJPROP_PRICE1);
    double p2 = ObjectGet("trend_high",OBJPROP_PRICE2);

    
    return 0;
  }
  
    
  /**
   * 画低线
   */
   
  int draw_low_line(){
      
    int shift1 = iLowest(Symbol(),Period(),MODE_LOW,15,4);
    if(is_low_point(shift1) == false){
      search_low_point(shift1);
    }
    
    int shift2 = iLowest(Symbol(),Period(),MODE_LOW,30,shift1+1);
    if(is_low_point(shift2) == false){
      search_low_point(shift2);
    }
    
    int shift3 = iLowest(Symbol(),Period(),MODE_LOW,30,shift2+1);
    if(is_low_point(shift3) == false){
      search_low_point(shift3);
    }

    datetime time1 = iTime(Symbol(),Period(),shift1);
    double price1  = iLow(Symbol(),Period(),shift1);
    
    datetime time2 = iTime(Symbol(),Period(),shift2);
    double price2  = iLow(Symbol(),Period(),shift2);
    
    datetime time3 = iTime(Symbol(),Period(),shift3);
    double price3  = iLow(Symbol(),Period(),shift3);
  
    ObjectCreate("trend_low",OBJ_TREND,0,time3,price3,time2,price2);
    
    datetime t1 = ObjectGet("trend_low",OBJPROP_TIME1);
    datetime t2 = ObjectGet("trend_low",OBJPROP_TIME2);
    
    double p1 = ObjectGet("trend_low",OBJPROP_PRICE1);
    double p2 = ObjectGet("trend_low",OBJPROP_PRICE2);

    
    return 0;
    
  }
  

  
  /**
   * 判断是不是高点
   */
  bool is_high_point(int point){
   
    double price = iHigh(Symbol(),Period(),point);
    int shift1 = iHighest(Symbol(),Period(),MODE_HIGH,3,point);
    int shift2 = iHighest(Symbol(),Period(),MODE_HIGH,3,point-3);
    
    if(shift1 == point && shift2 == point){
       return true;
    }else{
       return false;
    }

  }
  
    /**
   * 判断是不是低点
   */
  bool is_low_point(int point){
  
    double price = iLow(Symbol(),Period(),point);
    int shift1 = iLowest(Symbol(),Period(),MODE_LOW,3,point);
    int shift2 = iLowest(Symbol(),Period(),MODE_LOW,3,point-3);
    
    if(shift1 == point && shift2 == point){
       return true;
    }else{
       return false;
    }
    
  }
  
  
    
  int  search_high_point(int num){
     
  
   double cur_price = iHigh(Symbol(),Period(),num);
   
   int that_shift = iHighest(Symbol(),Period(),MODE_HIGH,3,num);
   double that_price = iHigh(Symbol(),Period(),that_shift);
  
   if(that_price > cur_price){
     int a = search_high_point(that_shift);
     return a;
   }else{
     return num;
   }
  
  }
  
   int  search_low_point(int num){
     
  
   double cur_price = iLow(Symbol(),Period(),num);
   
   int that_shift = iLowest(Symbol(),Period(),MODE_HIGH,3,num);
   double that_price = iLow(Symbol(),Period(),that_shift);
  
   if(that_price < cur_price){
     int a = search_low_point(that_shift);
     return a;
   }else{
     return num;
   }
  
  }
  

  


  
