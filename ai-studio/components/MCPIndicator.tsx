import React from 'react';
import { Wifi, Radio, Zap } from 'lucide-react';

interface MCPIndicatorProps {
  connected: boolean;
  processing: boolean;
}

export const MCPIndicator: React.FC<MCPIndicatorProps> = ({ connected, processing }) => {
  return (
    <div className="flex items-center gap-2 bg-white/90 backdrop-blur-sm pl-2 pr-3 py-1.5 rounded-full shadow-sm border border-slate-200/50">
      <div className="relative flex items-center justify-center w-2 h-2">
        {connected && (
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
        )}
        <span className={`relative inline-flex rounded-full h-2 w-2 ${connected ? 'bg-primary' : 'bg-slate-400'}`}></span>
      </div>
      <div className="flex flex-col leading-none">
        <span className="text-[10px] font-bold text-slate-700 tracking-wide">MCP LINK</span>
        <span className="text-[8px] text-slate-400 font-medium">
            {processing ? 'PROCESSING...' : connected ? 'ONLINE' : 'OFFLINE'}
        </span>
      </div>
      {processing && <Zap size={12} className="text-yellow-500 fill-current animate-pulse ml-1" />}
    </div>
  );
};
