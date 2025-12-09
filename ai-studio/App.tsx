import React, { useState, useEffect } from 'react';
import { 
  MapPin, Bell, Search, Car, Utensils, 
  ShoppingBag, Stethoscope, Briefcase, Truck, 
  MoreHorizontal, ArrowRight, Zap 
} from 'lucide-react';

import { ServiceCard } from './components/ServiceCard';
import { TaskQueue } from './components/TaskQueue';
import { MCPIndicator } from './components/MCPIndicator';
import { BottomNav } from './components/BottomNav';
import { AIAssistantModal } from './components/AIAssistantModal';
import { TaskDetailModal } from './components/TaskDetailModal';
import { AccountView } from './components/AccountView';
import { PayView } from './components/PayView';
import { ActivityView } from './components/ActivityView';

import { Task, TaskStatus, ServiceType, ExecutionStep } from './types';
import { parseUserIntent } from './services/geminiService';

const FilterChip: React.FC<{
  label: string;
  isActive: boolean;
  onClick: () => void;
}> = ({ label, isActive, onClick }) => (
  <button
    onClick={onClick}
    className={`whitespace-nowrap px-3 py-1.5 rounded-full text-xs font-medium transition-all border active:scale-95 ${
      isActive
        ? 'bg-slate-800 text-white border-slate-800 shadow-sm'
        : 'bg-white text-slate-500 border-slate-200 hover:border-slate-300 hover:text-slate-700'
    }`}
  >
    {label}
  </button>
);

const App: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [filterStatus, setFilterStatus] = useState<TaskStatus | 'ALL'>('ALL');
  const [selectedTaskId, setSelectedTaskId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState('home');

  // Derived state for the modal
  const selectedTask = tasks.find(t => t.id === selectedTaskId) || null;

  // Initialize with some mock data for "Activity Feed" feel
  useEffect(() => {
    setMounted(true);
    setTasks([
      {
        id: '1',
        title: 'Grocery Delivery',
        description: 'FairPrice Finest - 12 items',
        status: TaskStatus.COMPLETED,
        serviceType: ServiceType.MART,
        timestamp: Date.now() - 100000,
        mcpAgentName: 'MartBot',
        price: 'S$45.20',
        executionSteps: [
          { id: '1-1', label: 'Order Received', status: TaskStatus.COMPLETED, timestamp: Date.now() - 100000 },
          { id: '1-2', label: 'Shopper Assigned', status: TaskStatus.COMPLETED, timestamp: Date.now() - 90000 },
          { id: '1-3', label: 'Items Packed', status: TaskStatus.COMPLETED, timestamp: Date.now() - 80000 },
          { id: '1-4', label: 'Delivered', status: TaskStatus.COMPLETED, timestamp: Date.now() - 60000 },
        ]
      },
      {
        id: '2',
        title: 'Ride to Changi Airport',
        description: 'Terminal 3, Door 4',
        status: TaskStatus.COMPLETED,
        serviceType: ServiceType.TRANSPORT,
        timestamp: Date.now() - 2000000,
        mcpAgentName: 'TransportBot',
        price: 'S$24.50',
        executionSteps: [
          { id: '2-1', label: 'Request Received', status: TaskStatus.COMPLETED, timestamp: Date.now() - 2000000 },
          { id: '2-2', label: 'Driver Assigned', status: TaskStatus.COMPLETED, timestamp: Date.now() - 1900000 },
          { id: '2-3', label: 'Arrived at Destination', status: TaskStatus.COMPLETED, timestamp: Date.now() - 1500000 },
        ]
      }
    ]);
  }, []);

  // Simulation Engine: Updates tasks in "IN_PROGRESS" state
  useEffect(() => {
    const interval = setInterval(() => {
      setTasks(currentTasks => {
        return currentTasks.map(task => {
          if (task.status !== TaskStatus.IN_PROGRESS) return task;

          const steps = [...task.executionSteps];
          // Find the first non-completed step
          const activeStepIndex = steps.findIndex(s => s.status !== TaskStatus.COMPLETED);

          // If all steps completed, but task is still IN_PROGRESS, mark task as COMPLETED
          if (activeStepIndex === -1) {
            return { ...task, status: TaskStatus.COMPLETED };
          }

          const activeStep = steps[activeStepIndex];

          // Logic to progress the step
          if (activeStep.status === TaskStatus.PENDING) {
             // Start the step
             steps[activeStepIndex] = { ...activeStep, status: TaskStatus.IN_PROGRESS, timestamp: Date.now() };
             return { ...task, executionSteps: steps };
          } else if (activeStep.status === TaskStatus.IN_PROGRESS) {
             // Complete the step and move to next (simulated random delay chance)
             if (Math.random() > 0.3) {
                steps[activeStepIndex] = { ...activeStep, status: TaskStatus.COMPLETED };
                // Also trigger next step immediately to PENDING if exists
                // The next loop will pick it up to IN_PROGRESS
             }
             return { ...task, executionSteps: steps };
          }

          return task;
        });
      });
    }, 1500); // Update every 1.5 seconds

    return () => clearInterval(interval);
  }, []);

  const generateStepsForType = (type: ServiceType): ExecutionStep[] => {
    const baseSteps = (labels: string[]) => labels.map((label, idx) => ({
      id: `step-${Date.now()}-${idx}`,
      label,
      status: idx === 0 ? TaskStatus.IN_PROGRESS : TaskStatus.PENDING,
      timestamp: idx === 0 ? Date.now() : undefined
    }));

    switch (type) {
      case ServiceType.TRANSPORT:
        return baseSteps(['Request Received', 'Locating Nearby Drivers', 'Driver Assigned', 'Driver En Route', 'Arrived at Pickup']);
      case ServiceType.FOOD:
        return baseSteps(['Order Placed', 'Merchant Confirming', 'Preparing Food', 'Rider Picked Up', 'Delivered']);
      case ServiceType.MART:
        return baseSteps(['Order Received', 'Shopper Assigned', 'Picking Items', 'Checkout Complete', 'Out for Delivery']);
      case ServiceType.HEALTH:
        return baseSteps(['Appointment Requested', 'Checking Doctor Availability', 'Slot Reserved', 'Confirmation Sent']);
      default:
        return baseSteps(['Analyzing Request', 'Identifying Agent', 'Processing', 'Finalizing Task']);
    }
  };

  const handleCreateTask = async (text: string) => {
    setIsProcessing(true);
    
    // Simulate initial latency for "thinking"
    await new Promise(resolve => setTimeout(resolve, 600));

    try {
      const intent = await parseUserIntent(text);
      const serviceType = intent.serviceType as ServiceType;
      
      const newTask: Task = {
        id: Date.now().toString(),
        title: intent.title,
        description: intent.description,
        status: TaskStatus.IN_PROGRESS,
        serviceType: serviceType,
        timestamp: Date.now(),
        mcpAgentName: intent.mcpAgentName,
        price: intent.price,
        eta: intent.eta,
        executionSteps: generateStepsForType(serviceType)
      };

      setTasks(prev => [...prev, newTask]);
      
      // Auto-open detail view to show the magic
      setSelectedTaskId(newTask.id);

    } catch (error) {
      console.error("Task creation failed", error);
    } finally {
      setIsProcessing(false);
      setIsModalOpen(false);
    }
  };

  const filteredTasks = tasks.filter(task => {
    if (filterStatus === 'ALL') return true;
    return task.status === filterStatus;
  });

  const services = [
    { id: 'transport', label: 'Transport', icon: <Car size={26} className="text-primary" />, type: ServiceType.TRANSPORT },
    { id: 'food', label: 'Food', icon: <Utensils size={26} className="text-coral" />, type: ServiceType.FOOD },
    { id: 'mart', label: 'Mart', icon: <ShoppingBag size={26} className="text-purple-500" />, type: ServiceType.MART },
    { id: 'health', label: 'Health', icon: <Stethoscope size={26} className="text-blue-500" />, type: ServiceType.HEALTH },
    { id: 'express', label: 'Express', icon: <Truck size={26} className="text-orange-500" />, type: ServiceType.DELIVERY },
    { id: 'finance', label: 'Finance', icon: <Briefcase size={26} className="text-indigo-500" />, type: ServiceType.FINANCE },
    { id: 'more', label: 'More', icon: <MoreHorizontal size={26} className="text-slate-400" />, type: ServiceType.GENERAL },
  ];

  const renderHomeContent = () => (
    <div className="animate-in fade-in duration-300">
      {/* Services Grid */}
      <section className="pt-6 px-4">
        <div className="grid grid-cols-4 gap-y-4">
          {services.map(s => (
            <ServiceCard 
              key={s.id}
              label={s.label}
              icon={s.icon}
              onClick={() => console.log(`Clicked ${s.label}`)}
              isPromo={s.id === 'food'}
            />
          ))}
        </div>
      </section>

      {/* Active Tasks / MCP Queue */}
      <section className="mt-8 px-5">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-lg font-bold text-slate-800">Active Tasks</h2>
          <button 
            onClick={() => setActiveTab('activity')}
            className="text-xs font-medium text-primary hover:text-primary-dark transition-colors"
          >
            View All
          </button>
        </div>

        {/* Filter Chips */}
        <div className="flex gap-2 mb-4 overflow-x-auto no-scrollbar pb-1">
          <FilterChip 
            label="All" 
            isActive={filterStatus === 'ALL'} 
            onClick={() => setFilterStatus('ALL')} 
          />
          <FilterChip 
            label="Pending" 
            isActive={filterStatus === TaskStatus.PENDING} 
            onClick={() => setFilterStatus(TaskStatus.PENDING)} 
          />
          <FilterChip 
            label="Running" 
            isActive={filterStatus === TaskStatus.IN_PROGRESS} 
            onClick={() => setFilterStatus(TaskStatus.IN_PROGRESS)} 
          />
          <FilterChip 
            label="Completed" 
            isActive={filterStatus === TaskStatus.COMPLETED} 
            onClick={() => setFilterStatus(TaskStatus.COMPLETED)} 
          />
          <FilterChip 
            label="Failed" 
            isActive={filterStatus === TaskStatus.FAILED} 
            onClick={() => setFilterStatus(TaskStatus.FAILED)} 
          />
        </div>

        <TaskQueue 
          tasks={filteredTasks} 
          onTaskClick={(task) => setSelectedTaskId(task.id)} 
        />
      </section>

      {/* Promotional / Discovery Banner */}
      <section className="mt-8 px-5">
         <div className="w-full h-32 bg-gradient-to-r from-primary to-emerald-600 rounded-2xl shadow-lg relative overflow-hidden flex items-center px-6">
            <div className="text-white relative z-10 max-w-[70%]">
              <h3 className="font-bold text-lg mb-1">MCP Auto-Topup</h3>
              <p className="text-xs text-emerald-100 mb-3">Let AI manage your EZ-Link card balance automatically.</p>
              <button className="bg-white text-primary text-xs font-bold px-3 py-1.5 rounded-lg shadow-sm active:scale-95 transition-transform">Activate</button>
            </div>
            <div className="absolute right-0 bottom-0 opacity-20 transform translate-x-4 translate-y-4">
               <Zap size={100} className="text-white" />
            </div>
         </div>
      </section>

      {/* Recent Activity */}
      <section className="mt-8 px-5 pb-8">
        <h2 className="text-lg font-bold text-slate-800 mb-3">For You</h2>
         <div className="grid grid-cols-2 gap-3">
            <div className="bg-white p-3 rounded-xl shadow-sm border border-slate-100">
               <div className="w-8 h-8 rounded-full bg-coral/10 flex items-center justify-center mb-2">
                  <Utensils size={14} className="text-coral" />
               </div>
               <p className="text-xs font-bold text-slate-700">Reorder Lunch</p>
               <p className="text-[10px] text-slate-500 mt-1">Chicken Rice Set A</p>
            </div>
            <div className="bg-white p-3 rounded-xl shadow-sm border border-slate-100">
               <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center mb-2">
                  <Car size={14} className="text-blue-500" />
               </div>
               <p className="text-xs font-bold text-slate-700">Home to Office</p>
               <p className="text-[10px] text-slate-500 mt-1">S$14.20 • 25 mins</p>
            </div>
         </div>
      </section>
    </div>
  );

  if (!mounted) return null;

  return (
    <div className="min-h-screen bg-slate-50 flex justify-center">
      {/* Mobile Container Limit */}
      <div className="w-full max-w-md bg-slate-50 shadow-2xl relative min-h-screen pb-24 flex flex-col">
        
        {/* Header Section */}
        <header className="bg-white sticky top-0 z-30 pt-safe-top">
          {/* Top Bar */}
          <div className="px-5 py-3 flex justify-between items-center border-b border-slate-50">
            <div className="flex flex-col">
               <div className="flex items-center gap-1 text-slate-500 text-xs font-medium">
                  <MapPin size={12} className="text-primary" />
                  <span>Current Location</span>
               </div>
               <span className="text-sm font-bold text-slate-800 flex items-center gap-1">
                 Marina One, Singapore
                 <ArrowRight size={12} className="text-slate-400" />
               </span>
            </div>
            <div className="flex items-center gap-3">
               <MCPIndicator connected={true} processing={isProcessing} />
               <div className="relative">
                 <Bell size={22} className="text-slate-700" />
                 <span className="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full border border-white"></span>
               </div>
            </div>
          </div>

          {/* Search / Ask Bar (Fake) - Only show on Home */}
          {activeTab === 'home' && (
            <div className="px-5 py-3 bg-white shadow-sm">
              <button 
                onClick={() => setIsModalOpen(true)}
                className="w-full bg-slate-100 h-12 rounded-xl flex items-center px-4 gap-3 text-slate-500 hover:bg-slate-200 transition-colors"
              >
                  <Search size={20} />
                  <span className="text-sm font-medium">Where to? What to eat?</span>
              </button>
            </div>
          )}
        </header>

        {/* Scrollable Content */}
        <main className="flex-1 overflow-y-auto no-scrollbar">
          {activeTab === 'home' && renderHomeContent()}
          {activeTab === 'activity' && (
            <ActivityView tasks={tasks} onTaskClick={(task) => setSelectedTaskId(task.id)} />
          )}
          {activeTab === 'pay' && <PayView />}
          {activeTab === 'account' && <AccountView />}
        </main>

        {/* Bottom Nav */}
        <BottomNav 
          onFabClick={() => setIsModalOpen(true)}
          activeTab={activeTab}
          onTabChange={setActiveTab}
        />

        {/* AI Modal */}
        <AIAssistantModal 
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          onSubmit={handleCreateTask}
          isProcessing={isProcessing}
        />

        {/* Task Detail Modal */}
        <TaskDetailModal 
          task={selectedTask}
          onClose={() => setSelectedTaskId(null)}
        />
      </div>
    </div>
  );
};

export default App;
