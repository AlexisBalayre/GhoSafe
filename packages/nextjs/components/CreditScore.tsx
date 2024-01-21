import React from 'react';

interface CreditScoreProps {
  score: number; // Assuming score is from 0 to 100
}

const CreditScore: React.FC<CreditScoreProps> = ({ score }) => {
  const getScoreClass = (score: number): string => {
    if (score < 400) return 'text-error';
    if (score < 700) return 'text-warning';
    return 'text-success';
  };

  return (
    <div className={`radial-progress ${getScoreClass(score)}`} style={{ '--value': score } as React.CSSProperties}>
       {score+""}
    </div>
  );
};

export default CreditScore;
