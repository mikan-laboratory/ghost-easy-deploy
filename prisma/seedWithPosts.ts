import { PrismaClient } from '@prisma/client';
import { seedCommon } from './seedCommon';
import { seedPosts } from './seedPosts';

export const seedWithPosts = async (prisma: PrismaClient): Promise<void> => {
  await prisma.$executeRawUnsafe('PRAGMA foreign_keys = OFF;');

  const user = await seedCommon(prisma);

  await seedPosts({ user, prisma });

  await prisma.$executeRawUnsafe('PRAGMA foreign_keys = ON;');
};
