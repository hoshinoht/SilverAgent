import React from 'react';
import { User, Shield, ChevronRight, LogOut, FileText, Bell, Lock, HelpCircle } from 'lucide-react';

export const AccountView: React.FC = () => {
  // Mock Singpass data
  const user = {
    name: "Tan Wei Ming",
    nric: "S****872G",
    address: "Blk 88 Merlion Avenue, #08-88",
    email: "weiming.tan@example.com",
    mobile: "+65 9123 4567"
  };

  return (
    <div className="p-5 pb-24 animate-in fade-in duration-300">
      {/* Header */}
      <div className="mb-6 pt-2">
        <h2 className="text-2xl font-bold text-slate-800">Account</h2>
        <div className="flex items-center gap-2 mt-2 px-3 py-1.5 bg-red-50 text-red-600 rounded-lg w-fit border border-red-100">
          <Shield size={14} className="fill-current" />
          <span className="text-xs font-bold tracking-wide">Verified with Singpass</span>
        </div>
      </div>

      {/* Profile Card */}
      <div className="bg-white p-5 rounded-2xl shadow-sm border border-slate-100 mb-6 flex items-center gap-4">
        <div className="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 border-2 border-slate-50">
          <User size={32} />
        </div>
        <div>
          <h3 className="font-bold text-lg text-slate-800">{user.name}</h3>
          <p className="text-slate-500 text-sm">{user.email}</p>
        </div>
      </div>

      {/* Personal Info */}
      <div className="space-y-4 mb-8">
        <h4 className="text-xs font-bold text-slate-400 uppercase tracking-wider ml-1">Personal Info</h4>
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-4 border-b border-slate-50 flex justify-between items-center hover:bg-slate-50/50 transition-colors">
            <span className="text-slate-600 text-sm">Mobile</span>
            <span className="font-medium text-slate-800 text-sm">{user.mobile}</span>
          </div>
          <div className="p-4 border-b border-slate-50 flex justify-between items-center hover:bg-slate-50/50 transition-colors">
            <span className="text-slate-600 text-sm">NRIC</span>
            <span className="font-medium text-slate-800 text-sm">{user.nric}</span>
          </div>
          <div className="p-4 flex justify-between items-start gap-4 hover:bg-slate-50/50 transition-colors">
            <span className="text-slate-600 text-sm whitespace-nowrap">Address</span>
            <span className="font-medium text-slate-800 text-sm text-right leading-snug">{user.address}</span>
          </div>
        </div>
      </div>

      {/* Menu Items */}
      <div className="space-y-2.5">
        {[
          { label: 'Payment Methods', icon: <FileText size={18} className="text-slate-400" /> },
          { label: 'Notification Settings', icon: <Bell size={18} className="text-slate-400" /> },
          { label: 'Privacy & Security', icon: <Lock size={18} className="text-slate-400" /> },
          { label: 'Help Centre', icon: <HelpCircle size={18} className="text-slate-400" /> }
        ].map((item, idx) => (
          <button 
            key={idx} 
            className="w-full bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex justify-between items-center active:scale-[0.98] transition-all hover:shadow-md"
          >
            <div className="flex items-center gap-3">
              {item.icon}
              <span className="text-slate-700 font-medium text-sm">{item.label}</span>
            </div>
            <ChevronRight size={16} className="text-slate-400" />
          </button>
        ))}
      </div>

      <button className="w-full mt-8 p-4 rounded-xl border border-slate-200 text-red-500 font-bold text-sm flex items-center justify-center gap-2 hover:bg-red-50 transition-colors active:scale-[0.98]">
        <LogOut size={16} />
        Log Out
      </button>
      
      <div className="mt-8 text-center">
        <p className="text-[10px] text-slate-400">Version 2.4.0 (Build 892)</p>
      </div>
    </div>
  );
};