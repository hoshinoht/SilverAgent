import React, { useState, useEffect, useRef } from 'react';
import { Mic, Send, X, Sparkles } from 'lucide-react';

interface AIAssistantModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (text: string) => void;
  isProcessing: boolean;
}

export const AIAssistantModal: React.FC<AIAssistantModalProps> = ({ isOpen, onClose, onSubmit, isProcessing }) => {
  const [inputText, setInputText] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (isOpen && inputRef.current) {
      setTimeout(() => inputRef.current?.focus(), 100);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (inputText.trim()) {
      onSubmit(inputText);
      setInputText('');
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center sm:items-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
      <div 
        className="bg-white w-full max-w-md rounded-3xl shadow-2xl overflow-hidden animate-in slide-in-from-bottom-10 duration-300"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="bg-gradient-to-r from-primary to-emerald-500 p-6 text-white relative">
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full transition-colors"
          >
            <X size={18} />
          </button>
          <div className="flex items-center gap-3 mb-2">
            <div className="p-2 bg-white/20 rounded-xl">
               <Sparkles size={20} className="text-white" />
            </div>
            <h3 className="font-bold text-lg">SingaSuper MCP</h3>
          </div>
          <p className="text-emerald-50 text-sm leading-relaxed">
            I can help you book rides, order food, or schedule appointments. Try asking "Book a ride to Marina Bay".
          </p>
        </div>

        {/* Input Area */}
        <div className="p-4 bg-slate-50">
          <form onSubmit={handleSubmit} className="relative">
            <input
              ref={inputRef}
              type="text"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              placeholder="What do you need done?"
              className="w-full pl-4 pr-12 py-4 rounded-xl border border-slate-700 bg-slate-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-white placeholder:text-slate-400"
              disabled={isProcessing}
            />
            <button 
              type="submit"
              disabled={!inputText.trim() || isProcessing}
              className={`absolute right-2 top-2 bottom-2 aspect-square flex items-center justify-center rounded-lg transition-all ${
                inputText.trim() && !isProcessing ? 'bg-primary text-white shadow-md' : 'bg-slate-700 text-slate-500'
              }`}
            >
              {isProcessing ? (
                <div className="w-5 h-5 border-2 border-white/50 border-t-white rounded-full animate-spin" />
              ) : (
                <Send size={18} />
              )}
            </button>
          </form>
          
          {/* Quick Suggestions */}
          <div className="mt-4 flex gap-2 overflow-x-auto no-scrollbar pb-2">
            {['Ride to Office', 'Chicken Rice @ Maxwell', 'Pay Bills'].map((s) => (
              <button 
                key={s}
                onClick={() => setInputText(s)}
                className="whitespace-nowrap px-3 py-1.5 bg-white border border-slate-200 rounded-full text-xs font-medium text-slate-600 hover:border-primary hover:text-primary transition-colors"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
