class OneNodeNetwork:
    """
    A class to hold the queueing network object
    """
    def __init__(self, n1, mu1, r11, L1):
        """
        Initialises the Network object
        """
        self.n1 = n1
        self.mu1 = mu1
        self.r11 = r11
        self.L1 = L1
        self.State_Space = [(i) for i in range(self.n1+2)] + [-1]
        self.write_transition_matrix()
        self.discretise_transition_matrix()

    def find_transition_rates(self, state1, state2):
        """
        Finds the transition rates for given state transition
        """
        if state1 == -1:
            return 0
        if state2 == -1:
            if state1 == self.n1 + 1:
                return self.r11*self.mu1
            else:
                return 0
        else:
            delta = (state2-state1)
            if delta == 1:
                if state1<self.n1+1:
                    return self.L1
                return 0
            if delta == -1:
                return (1-self.r11)*self.mu1
        return 0

    def write_transition_matrix(self):
        """
        Writes the transition matrix for the markov chain
        """
        b = [[self.find_transition_rates(s1, s2) for s2 in self.State_Space] for s1 in self.State_Space]
        for i in range(len(self.State_Space)):
            a = sum(b[i])
            b[i][i] = -a
            self.transition_matrix = matrix(QQ, b)

    def discretise_transition_matrix(self):
        """
        Disctetises the transition matrix
        """
        self.time_step = 1 / max([abs(self.transition_matrix[i][i]) for i in range(len(self.State_Space))])
        self.discrete_transition_matrix = self.transition_matrix*self.time_step + matrix.identity(len(self.State_Space))

    def find_mean_time_to_absorbtion(self):
        """
        Finds the mean time to absorbtion
        """
        T = self.discrete_transition_matrix[:-1, :-1]
        S = ~(matrix.identity(len(self.State_Space)-1) - T)
        steps2absorb = [sum([S[i,j] for j in range(len(self.State_Space)-1)]) for i in range(len(self.State_Space)-1)]
        time2absorb = [s*self.time_step for s in steps2absorb]
        self.mean_steps_to_absorbtion = {str(self.State_Space[i]): steps2absorb[i] for i in range(len(steps2absorb))}
        self.mean_time_to_absorbtion = {str(self.State_Space[i]): float(time2absorb[i]) for i in range(len(time2absorb))}



class TwoNodeSimpleNetwork:
    """
    A class to hold the queueing network object
    """

    def __init__(self, n1, n2, mu1, mu2, r12, r21, L1, L2):
        """
        Initialises the Network object
        """
        self.n1 = n1
        self.n2 = n2
        self.mu1 = mu1
        self.mu2 = mu2
        self.r12 = r12
        self.r21 = r21
        self.L1 = L1
        self.L2 = L2
        self.State_Space = [(i, j) for i in range(self.n1+3) for j in range(self.n2+3) if i+j<=self.n1+self.n2+2] + [-1]
        self.write_transition_matrix()
        self.discretise_transition_matrix()

    def find_transition_rates(self, state1, state2):
        """
        Finds the transition rates for given state transition
        """
        if state1 == -1:
            return 0
        if state2 == -1:
            if state1[0] == self.n1 and state1[1] == self.n2 + 2:
                return self.r21 * self.mu2
            if state1[0] == self.n1 + 2 and state1[1] == self.n2:
                return self.r12 * self.mu1
            else:
                return 0
        else:
            delta = (state2[0] - state1[0], state2[1] - state1[1])
            if delta == (1, 0):
                if state1[0] < self.n1 + 1:
                    return self.L1
                return 0
            if delta == (0, 1):
                if state1[1] < self.n2 + 1:
                    return self.L2
                return 0
            if delta == (-1, 0):
                if state1[1] < self.n2 + 2:
                    return (1 - self.r12) * self.mu1
                return 0
            if delta == (0, -1):
                if state1[0] < self.n1 + 2:
                    return (1 - self.r21) * self.mu2
                return 0
            if delta == (-1, 1):
                if state1[1] < self.n2 + 2 and (state1[0], state1[1]) != (self.n1+2, self.n2):
                    return self.r12 * self.mu1
                return 0
            if delta == (1, -1):
                if state1[0] < self.n1 + 2 and (state1[0], state1[1]) != (self.n1, self.n2+2):
                    return self.r21 * self.mu2
                return 0
            return 0

    def write_transition_matrix(self):
        """
        Writes the transition matrix for the markov chain
        """
        b = [[self.find_transition_rates(s1, s2) for s2 in self.State_Space] for s1 in self.State_Space]
        for i in range(len(self.State_Space)):
            a = sum(b[i])
            b[i][i] = -a
            self.transition_matrix = matrix(QQ, b)

    def discretise_transition_matrix(self):
        """
        Disctetises the transition matrix
        """
        self.time_step = 1 / max([abs(self.transition_matrix[i][i]) for i in range(len(self.State_Space))])
        self.discrete_transition_matrix = self.transition_matrix*self.time_step + matrix.identity(len(self.State_Space))

    def find_mean_time_to_absorbtion(self):
        """
        Finds the mean time to absorbtion
        """
        T = self.discrete_transition_matrix[:-1, :-1]
        S = ~(matrix.identity(len(self.State_Space)-1) - T)
        steps2absorb = [sum([S[i,j] for j in range(len(self.State_Space)-1)]) for i in range(len(self.State_Space)-1)]
        time2absorb = [s*self.time_step for s in steps2absorb]
        self.mean_steps_to_absorbtion = {str(self.State_Space[i]): steps2absorb[i] for i in range(len(steps2absorb))}
        self.mean_time_to_absorbtion = {str(self.State_Space[i]): float(time2absorb[i]) for i in range(len(time2absorb))}


class TwoNodeFeedbackNetwork:
    """
    A class to hold the queueing network object
    """

    def __init__(self, n1, n2, mu1, mu2, r11, r12, r21, r22, L1, L2):
        """
        Initialises the Network object
        """
        self.n1 = n1
        self.n2 = n2
        self.mu1 = mu1
        self.mu2 = mu2
        self.r11 = r11
        self.r12 = r12
        self.r21 = r21
        self.r22 = r22
        self.L1 = L1
        self.L2 = L2
        self.State_Space = [(i, j) for i in range(self.n1+3) for j in range(self.n2+3) if i+j<=self.n1+self.n2+2] + [-1, -2, -3]
        self.write_transition_matrix()
        self.discretise_transition_matrix()

    def find_transition_rates(self, state1, state2):
        """
        Finds the transition rates for given state transition
        """
        if state1 in [-1, -2, -3]:
            return 0
        if state2 == -3:
            if state1[0] == self.n1 and state1[1] == self.n2 + 2:
                return self.r21 * self.mu2
            if state1[0] == self.n1 + 2 and state1[1] == self.n2:
                return self.r12 * self.mu1
            else:
                return 0
        elif state2 == -1:
            if state1[0] >= self.n1+1 and state1[1] < self.n2+2:
                return self.r11*self.mu1
            else:
                return 0
        elif state2 == -2:
            if state1[1] >= self.n2+1 and state1[0] < self.n1+2:
                return self.r22*self.mu2
            else:
                return 0
        else:
            delta = (state2[0] - state1[0], state2[1] - state1[1])
            if delta == (1, 0):
                if state1[0] < self.n1 + 1:
                    return self.L1
                return 0
            if delta == (0, 1):
                if state1[1] < self.n2 + 1:
                    return self.L2
                return 0
            if delta == (-1, 0):
                if state1[1] < self.n2 + 2:
                    return (1 - self.r12 - self.r11) * self.mu1
                return 0
            if delta == (0, -1):
                if state1[0] < self.n1 + 2:
                    return (1 - self.r21 - self.r22) * self.mu2
                return 0
            if delta == (-1, 1):
                if state1[1] < self.n2 + 2 and (state1[0], state1[1]) != (self.n1+2, self.n2):
                    return self.r12 * self.mu1
                return 0
            if delta == (1, -1):
                if state1[0] < self.n1 + 2 and (state1[0], state1[1]) != (self.n1, self.n2+2):
                    return self.r21 * self.mu2
                return 0
            return 0

    def write_transition_matrix(self):
        """
        Writes the transition matrix for the markov chain
        """
        b = [[self.find_transition_rates(s1, s2) for s2 in self.State_Space] for s1 in self.State_Space]
        for i in range(len(self.State_Space)):
            a = sum(b[i])
            b[i][i] = -a
            self.transition_matrix = matrix(QQ, b)

    def discretise_transition_matrix(self):
        """
        Disctetises the transition matrix
        """
        self.time_step = 1 / max([abs(self.transition_matrix[i][i]) for i in range(len(self.State_Space))])
        self.discrete_transition_matrix = self.transition_matrix*self.time_step + matrix.identity(len(self.State_Space))

    def find_mean_time_to_absorbtion(self):
        """
        Finds the mean time to absorbtion
        """
        T = self.discrete_transition_matrix[:-3, :-3]
        S = ~(matrix.identity(len(self.State_Space)-3) - T)
        steps2absorb = [sum([S[i,j] for j in range(len(self.State_Space)-3)]) for i in range(len(self.State_Space)-3)]
        time2absorb = [s*self.time_step for s in steps2absorb]
        self.mean_steps_to_absorbtion = {str(self.State_Space[i]): steps2absorb[i] for i in range(len(steps2absorb))}
        self.mean_time_to_absorbtion = {str(self.State_Space[i]): float(time2absorb[i]) for i in range(len(time2absorb))}
