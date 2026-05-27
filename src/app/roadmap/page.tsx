import { Roadmap } from "@/components/roadmap/Roadmap";
import { getAllProjectsForRoadmap } from "@/lib/db";

export default async function RoadmapPage() {
  const rows = await getAllProjectsForRoadmap();
  return <Roadmap rows={rows} />;
}
