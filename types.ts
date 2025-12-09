import React from 'react';

export enum TaskStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
}

export enum ServiceType {
  TRANSPORT = 'TRANSPORT',
  FOOD = 'FOOD',
  MART = 'MART',
  HEALTH = 'HEALTH',
  FINANCE = 'FINANCE',
  DELIVERY = 'DELIVERY',
  GENERAL = 'GENERAL'
}

export interface ExecutionStep {
  id: string;
  label: string;
  status: TaskStatus;
  timestamp?: number;
  details?: string;
}

export interface Task {
  id: string;
  title: string;
  description: string;
  status: TaskStatus;
  serviceType: ServiceType;
  timestamp: number;
  mcpAgentName?: string;
  eta?: string;
  price?: string;
  executionSteps: ExecutionStep[];
}

export interface QuickAction {
  id: string;
  label: string;
  icon: React.ReactNode;
  serviceType: ServiceType;
  prompt: string;
}

export interface UserProfile {
  name: string;
  location: string;
  walletBalance: number;
  points: number;
}