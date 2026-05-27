import { Roadmap } from "@/components/roadmap/Roadmap";
import { getAllProjectsForRoadmap } from "@/lib/mock";

export default function RoadmapPage() {
  return <Roadmap rows={getAllProjectsForRoadmap()} />;
}
