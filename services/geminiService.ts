import { GoogleGenAI, Type } from "@google/genai";
import { ServiceType, TaskStatus } from '../types';

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

// System instruction to guide the model to act as a Super App automation agent
const SYSTEM_INSTRUCTION = `
You are the automation engine for a Singaporean Super App called "SingaSuper".
Your job is to interpret user requests and convert them into structured tasks.
The user might say "Get me a car to Changi" or "Order chicken rice from Maxwell".
You must return a JSON object representing the task.
If the request is unclear, default to GENERAL service type.
The description should be concise.
Generate a realistic Singapore dollar price (e.g. S$15.50) and ETA (e.g. 15 mins) if applicable.
Valid Service Types: TRANSPORT, FOOD, MART, HEALTH, FINANCE, DELIVERY, GENERAL.
`;

export const parseUserIntent = async (userText: string) => {
  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: userText,
      config: {
        systemInstruction: SYSTEM_INSTRUCTION,
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            title: { type: Type.STRING, description: "Short title of the task" },
            description: { type: Type.STRING, description: "Details of the task" },
            serviceType: { type: Type.STRING, description: "One of the valid service types" },
            price: { type: Type.STRING, description: "Estimated price in SGD, e.g. S$12.00" },
            eta: { type: Type.STRING, description: "Estimated time of arrival or completion" },
            mcpAgentName: { type: Type.STRING, description: "Name of the sub-agent handling this, e.g. 'TransportBot', 'FoodRunner'" }
          },
          required: ["title", "description", "serviceType"]
        }
      }
    });

    const text = response.text;
    if (!text) throw new Error("No response from AI");
    
    return JSON.parse(text);
  } catch (error) {
    console.error("Gemini Intent Error:", error);
    // Fallback task if AI fails
    return {
      title: "Request Received",
      description: userText,
      serviceType: ServiceType.GENERAL,
      price: "-",
      eta: "Calculating...",
      mcpAgentName: "SupportAgent"
    };
  }
};
