import React from 'react';
import { QrCode, ArrowUpRight, ArrowDownLeft, CreditCard, History, ChevronRight } from 'lucide-react';

export const PayView: React.FC = () => {
  return (
    <div className="p-5 pb-24 animate-in fade-in duration-300">
      <div className="flex justify-between items-center mb-6 pt-2">
         <h2 className="text-2xl font-bold text-slate-800">Wallet</h2>
         <button className="p-2 rounded-full bg-slate-100 text-slate-600 hover:bg-slate-200">
            <History size={20} />
         </button>
      </div>

      {/* Card */}
      <div className="bg-gradient-to-br from-slate-800 to-slate-900 rounded-2xl p-6 text-white shadow-xl shadow-slate-200 mb-8 relative overflow-hidden group">
        <div className="absolute top-0 right-0 p-32 bg-primary opacity-10 rounded-full -translate-y-10 translate-x-10 blur-3xl group-hover:opacity-20 transition-opacity duration-500"></div>
        <div className="relative z-10">
          <div className="flex justify-between items-start mb-6">
             <p className="text-slate-400 text-xs font-bold uppercase tracking-widest">SingaPay Balance</p>
             <CreditCard size={20} className="text-slate-400" />
          </div>
          <h3 className="text-4xl font-bold mb-8 tracking-tight">S$ 88.80</h3>

          <div className="flex gap-3">
            <button className="flex-1 bg-white/10 backdrop-blur-md hover:bg-white/20 active:bg-white/30 transition-colors py-2.5 rounded-xl flex items-center justify-center gap-2 text-sm font-bold border border-white/5">
              <ArrowUpRight size={16} /> Top Up
            </button>
            <button className="flex-1 bg-primary text-white py-2.5 rounded-xl flex items-center justify-center gap-2 text-sm font-bold shadow-lg shadow-primary/20 hover:bg-primary/90 active:scale-95 transition-all">
              <QrCode size={16} /> Scan
            </button>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-4 gap-4 mb-8">
         {[
           { label: 'Transfer', icon: <ArrowDownLeft size={20} /> },
           { label: 'Bills', icon: <div className="font-serif font-bold text-lg leading-none">$</div> },
           { label: 'Rewards', icon: <div className="text-lg">🎁</div> },
           { label: 'More', icon: <div className="w-1 h-1 bg-current rounded-full mx-0.5 box-content border-2 border-transparent border-x-4"></div> }
         ].map((action, i) => (
           <button key={i} className="flex flex-col items-center gap-2 group">
              <div className="w-12 h-12 rounded-2xl bg-white border border-slate-100 shadow-sm flex items-center justify-center text-slate-700 group-hover:-translate-y-1 transition-transform">
                 {action.icon}
              </div>
              <span className="text-xs font-medium text-slate-600">{action.label}</span>
           </button>
         ))}
      </div>

      {/* Recent Transactions */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h4 className="text-lg font-bold text-slate-800">Recent Transactions</h4>
          <button className="text-primary text-xs font-bold flex items-center hover:underline">
             See All <ChevronRight size={12} />
          </button>
        </div>

        <div className="space-y-3">
          {[
            { title: 'GrabRide - Office', date: 'Today, 10:23 AM', amount: '-$14.20', icon: '🚗' },
            { title: 'Maxwell Chicken Rice', date: 'Yesterday, 1:15 PM', amount: '-$5.50', icon: '🍗' },
            { title: 'PayNow from J. Lim', date: '12 Oct, 4:30 PM', amount: '+$50.00', icon: '💸', isIncome: true },
            { title: '7-Eleven', date: '11 Oct, 8:45 PM', amount: '-$8.90', icon: '🏪' },
            { title: 'Gong Cha', date: '10 Oct, 2:15 PM', amount: '-$4.80', icon: '🧋' },
          ].map((tx, i) => (
            <div key={i} className="bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex items-center gap-4 hover:shadow-md transition-shadow cursor-pointer">
              <div className="w-10 h-10 rounded-full bg-slate-50 flex items-center justify-center text-lg border border-slate-100">
                {tx.icon}
              </div>
              <div className="flex-1">
                <h5 className="font-bold text-slate-800 text-sm">{tx.title}</h5>
                <p className="text-xs text-slate-500">{tx.date}</p>
              </div>
              <span className={`font-bold text-sm ${tx.isIncome ? 'text-green-600' : 'text-slate-800'}`}>
                {tx.amount}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};